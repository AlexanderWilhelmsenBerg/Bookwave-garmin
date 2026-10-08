import test from 'node:test';
import assert from 'node:assert/strict';
import http from 'node:http';
import { exchangeSession, createSessionBridge } from './bookwave-session.mjs';

const principal = {id:'fixture-id',username:'fixture',permissions:{download:true}};
function context(sessions={}) {
  return {sessions,authorize:async()=>principal,save:()=>{},uuid:()=> '01234567-89ab-4cde-8123-456789abcdef'};
}
test('validates the signed-in principal and issues only an opaque session', async()=>{
  const ctx=context();
  const result=await exchangeSession(ctx,'fixture-access','fixture');
  assert.equal(result.status,200);
  assert.equal(result.body.user.token,'01234567-89ab-4cde-8123-456789abcdef');
  assert.equal(result.body.renewal,'phone');
  assert.ok(!JSON.stringify(result).includes('fixture-access'));
  assert.equal(Object.values(ctx.sessions)[0].refresh,null);
});
test('reuses the existing Sidecar-owned refresh session without exporting a refresh token', async()=>{
  const sid='01234567-89ab-4cde-8123-456789abcdef';
  const ctx=context({[sid]:{user:'fixture',access:'old-access',refresh:'sidecar-owned-refresh'}});
  const result=await exchangeSession(ctx,'new-access','fixture');
  assert.equal(result.body.user.token,sid);assert.equal(result.body.renewal,'sidecar');
  assert.equal(ctx.sessions[sid].refresh,'sidecar-owned-refresh');
  assert.ok(!JSON.stringify(result).includes('sidecar-owned-refresh'));
});
test('foreign principal, revoked download grant and expired access create no sessions',async()=>{
  for(const who of [{...principal,username:'other'},{...principal,permissions:{download:false}},null]){
    const ctx=context();ctx.authorize=async()=>who;
    assert.notEqual((await exchangeSession(ctx,'fixture-access','fixture')).status,200);
    assert.equal(Object.keys(ctx.sessions).length,0);
  }
});
test('a supplied refresh token is never required or adopted',async()=>{
  const ctx=context();await exchangeSession(ctx,'fixture-access','fixture');
  assert.equal(Object.values(ctx.sessions)[0].refresh,null);
});
test('repeat setup refreshes the same session; another user retains separate ownership',async()=>{
  const ctx=context({'aaaaaaaa-bbbb-cccc-dddd-eeeeeeeeeeee':{user:'other',access:'other-access',refresh:'other-refresh'}});
  const first=await exchangeSession(ctx,'first-access','fixture');
  const second=await exchangeSession(ctx,'second-access','fixture');
  assert.equal(first.body.user.token,second.body.user.token);
  assert.equal(Object.keys(ctx.sessions).length,2);
  assert.equal(ctx.sessions['aaaaaaaa-bbbb-cccc-dddd-eeeeeeeeeeee'].access,'other-access');
});
async function withServer(action) {
  const ctx=context();const bridge=createSessionBridge(ctx);
  const server=http.createServer((req,res)=>{if(!bridge.handle(req,res,req.url)){res.writeHead(404).end();}});
  await new Promise(resolve=>server.listen(0,'127.0.0.1',resolve));
  try{await action(`http://127.0.0.1:${server.address().port}`,ctx);}
  finally{await new Promise(resolve=>server.close(resolve));}
}
test('HTTP capability and session fixtures preserve the wire contract',async()=>{
  await withServer(async(url,ctx)=>{
    const caps=await fetch(url+'/bookwave/capabilities');
    assert.deepEqual(await caps.json(),{v:1,features:['session']});
    const response=await fetch(url+'/bookwave/session',{method:'POST',headers:{Authorization:'Bearer fixture-access'},body:JSON.stringify({username:'fixture'})});
    assert.equal(response.status,200);assert.match(response.headers.get('content-type'),/application\/json/);
    assert.equal((await response.json()).user.username,'fixture');
    assert.equal(Object.keys(ctx.sessions).length,1);
  });
});
test('malformed, oversized and credential-bearing bodies are refused without a session',async()=>{
  await withServer(async(url,ctx)=>{
    for(const body of ['{',JSON.stringify({username:'fixture',refreshToken:'must-not-adopt'}),'x'.repeat(2048)]){
      const response=await fetch(url+'/bookwave/session',{method:'POST',headers:{Authorization:'Bearer fixture-access'},body});
      assert.notEqual(response.status,200);
    }
    assert.equal(Object.keys(ctx.sessions).length,0);
  });
});
