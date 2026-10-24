import {execFileSync} from 'node:child_process';
import {copyFileSync,mkdirSync} from 'node:fs';
execFileSync(process.execPath,['node_modules/vite/bin/vite.js','build'],{stdio:'inherit'});
copyFileSync('config.js','build/config.js');mkdirSync('build/assets',{recursive:true});copyFileSync('assets/logo.png','build/assets/logo.png');
