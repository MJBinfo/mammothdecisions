// check-html-script.mjs — CI syntax check for the inline <script> in index.html.
// Fails the build if the script can't even be parsed (e.g. a stray brace,
// unclosed template literal, etc.) before it ever reaches production.

import { readFileSync } from 'fs';

const html = readFileSync('index.html', 'utf8');
const match = html.match(/<script>([\s\S]*)<\/script>/);

if (!match) {
  console.error('No inline <script> tag found in index.html');
  process.exit(1);
}

try {
  new Function(match[1]);
  console.log('OK: index.html inline script parses without syntax errors');
} catch (err) {
  console.error('Syntax error in index.html inline script:');
  console.error(err.message);
  process.exit(1);
}
