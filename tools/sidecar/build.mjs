// Build an explicit, reproducible WatchShelf extension, without editing upstream or deployment.
import {readFile,writeFile,mkdir,copyFile} from 'node:fs/promises';
import {createHash} from 'node:crypto';
import {resolve,dirname,join} from 'node:path';
import {fileURLToPath} from 'node:url';
const root=resolve(dirname(fileURLToPath(import.meta.url)),'../..');
const source=resolve(process.argv[2]||'');
const output=join(root,'out','sidecar');
const upstream=await readFile(join(source,'sidecar','server.js'),'utf8');
if(createHash('sha256').update(upstream).digest('hex')!=='a0136f988af35cdc5422c02f6db8ff9a0cf600c1bfd1a8d82151f8945a5a5359'){
  throw new Error('Unrecognized WatchShelf server source. Use documented pin; do not overwrite a modified deployment.');
}
let patched="import { createSessionBridge } from './bookwave-session.mjs';\n"+upstream;
patched=patched.replace('const server = http.createServer',`const bookwave = createSessionBridge({
  sessions, save: saveSessions,
  authorize: async (token) => {
    const response = await fetch(ABS + '/api/authorize', {
      method: 'POST', headers: bearer(token), redirect: 'error', signal: AbortSignal.timeout(ABS_TIMEOUT_MS)
    });
    if (response.status === 401) { return null; }
    if (!response.ok) { throw new Error('ABS authorization unavailable'); }
    return ((await response.json()) || {}).user;
  }
});
const server = http.createServer`);
patched=patched.replace("  const g = req.method === 'GET';","  if (bookwave.handle(req, res, p)) { return; }\n  const g = req.method === 'GET';");
await mkdir(output,{recursive:true});await writeFile(join(output,'server.js'),patched);
await copyFile(join(source,'sidecar','package.json'),join(output,'package.json'));
await copyFile(join(root,'sidecar','bookwave-session.mjs'),join(output,'bookwave-session.mjs'));
let docker=await readFile(join(source,'sidecar','Dockerfile'),'utf8');
docker=docker.replace('COPY package.json server.js ./','COPY package.json server.js bookwave-session.mjs ./');
await writeFile(join(output,'Dockerfile'),docker);
await copyFile(join(root,'apps','audio-provider','third-party','WATCHSHELF-LICENSE.txt'),join(output,'WATCHSHELF-LICENSE.txt'));
console.log('Prepared out/sidecar; deployment has not been changed.');
