// BookWave extension to WatchShelf Sidecar. ABS credentials stay on phone/Sidecar, never the watch.
// POST /bookwave/session validates against Sidecar's configured ABS and returns an opaque UUID.
import { randomUUID } from 'node:crypto';
const headers={'Content-Type':'application/json','Cache-Control':'no-store'};
const reply=(status,body)=>({status,body});
export async function exchangeSession(ctx,access,expectedUsername) {
  if(typeof access!=='string'||access.length<1||access.length>8192||/[\r\n]/.test(access)||
     typeof expectedUsername!=='string'||!expectedUsername||expectedUsername.length>128){
    return reply(400,{error:'INVALID_REQUEST'});
  }
  // Authoritative identity/permissions, not unverified JWT claims or client-supplied username.
  const user=await ctx.authorize(access);
  if(!user){return reply(401,{error:'REAUTH_REQUIRED'});}
  if(typeof user.id!=='string'||!user.id||typeof user.username!=='string'){
    return reply(502,{error:'INCOMPATIBLE_ABS'});
  }
  if(user.username!==expectedUsername){return reply(403,{error:'ACCOUNT_MISMATCH'});}
  if(user.permissions?.download!==true){return reply(403,{error:'DOWNLOAD_DENIED'});}
  // Reuse Sidecar-owned refresh credentials from an existing on-watch login, when available.
  // Never import the phone's rotating refresh token: sharing it would break the Android session.
  const existing=Object.entries(ctx.sessions).filter(([,s])=>
    s.bookwaveUserId===user.id || (!s.bookwaveUserId && s.user===user.username));
  const match=existing.find(([,s])=>s.refresh)||existing[0];
  const sid=match?.[0]||(ctx.uuid||randomUUID)();
  const session=match?.[1]||{refresh:null};
  session.access=access;session.user=user.username;session.bookwaveUserId=user.id;
  ctx.sessions[sid]=session;ctx.save();
  return reply(200,{v:1,user:{token:sid,username:user.username},renewal:session.refresh?'sidecar':'phone'});
}
export function createSessionBridge(ctx) {
  return {
    handle(req,res,path) {
      if(path==='/bookwave/capabilities'&&req.method==='GET'){
        res.writeHead(200,headers).end(JSON.stringify({v:1,features:['session']}));return true;
      }
      if(path!=='/bookwave/session'||req.method!=='POST'){return false;}
      let size=0;let body='';let finished=false;
      const send=result=>{if(finished){return;}finished=true;res.writeHead(result.status,headers).end(JSON.stringify(result.body));};
      req.on('data',chunk=>{
        size+=chunk.length;if(size>1024){send(reply(413,{error:'INVALID_REQUEST'}));return;}
        body+=chunk.toString();
      });
      req.on('end',async()=>{
        if(finished){return;}
        try {
          let value;try{value=JSON.parse(body);}catch{send(reply(400,{error:'INVALID_REQUEST'}));return;}
          if(!value||Object.keys(value).some(k=>k!=='username')){send(reply(400,{error:'INVALID_REQUEST'}));return;}
          const authorization=req.headers.authorization||'';
          if(!authorization.startsWith('Bearer ')){send(reply(401,{error:'REAUTH_REQUIRED'}));return;}
          send(await exchangeSession(ctx,authorization.slice(7),value.username));
        } catch {send(reply(502,{error:'SIDECAR_UNAVAILABLE'}));}
      });
      req.on('error',()=>send(reply(400,{error:'INVALID_REQUEST'})));return true;
    }
  };
}
