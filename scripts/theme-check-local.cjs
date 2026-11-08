const path = require('node:path');
const { themeCheckRun } = require('./theme-tools/packages/theme-check-node/dist/index.js');

async function main() {
  const args = process.argv.slice(2);
  const usage = 'Usage: theme-check-local [--allow-custom-checks] THEME [CONFIG]';
  if (args.length === 1 && args[0] === '--help') {
    console.log(usage);
    return;
  }
  if (args.length === 1 && args[0] === '--version') {
    console.log(require('./BUILD_METADATA.json').theme_check_version);
    return;
  }
  const allow = args[0] === '--allow-custom-checks';
  if (allow) args.shift();
  if (args.length < 1 || args.length > 2 || args.some(arg => arg.startsWith('-'))) {
    console.error(usage);
    process.exitCode = 2;
    return;
  }
  const [root, config] = args.map(arg => path.resolve(arg));
  const { offenses } = await themeCheckRun(root, config, undefined, {
    authorizeCustomChecks: () => allow,
    onDiagnostic: diagnostic => console.error(diagnostic.message),
  });
  console.log(JSON.stringify(offenses, null, 2));
  process.exitCode = offenses.some(offense => offense.severity === 0) ? 1 : 0;
}

main().catch(error => {
  console.error(error.message);
  process.exitCode = 2;
});
