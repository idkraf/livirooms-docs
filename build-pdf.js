const fs = require('fs');
const path = require('path');
const { execSync } = require('child_process');

const files = [
  'README.md',
  'INDEX.md',
  'ai/00-orientation.md',
  'ai/01-backend-map.md',
  'ai/02-frontend-map.md',
  'ai/03-api-contract.md',
  'ai/04-drift-register.md',
  'ai/05-wizard-form-ui.md',
  'domain/hotel-vs-property.md',
  'domain/accommodations.md',
  'domain/property-hotel-form-sync.md',
  'features/property-management.md',
  'features/mitra-order-management.md',
  'features/payments.md',
  'features/referral.md',
  'features/account-menu.md',
  'payments/system.md',
  'configuration/admin-panel.md',
  'configuration/ui-patterns.md',
  'configuration/missing-files.md',
  'sfds.md',
  'mitra-accommodation-api.md',
  'workflows/run_api_sequence.xml',
  'manual/user-guide-mobile-app.md',
  'manual/user-guide-web-administrator.md',
  'manual/user-manual-web-administrator.md',
  'manual/user-manual-mobile-app.md'
];

let combinedMarkdown = `# Livirooms Complete Documentation\n\n`;

files.forEach(file => {
  const filePath = path.join(__dirname, file);
  if (fs.existsSync(filePath)) {
    console.log(`Processing: ${file}`);
    const content = fs.readFileSync(filePath, 'utf-8');
    
    // Add page break before each new document, except the very first title
    combinedMarkdown += `<div style="page-break-after: always;"></div>\n\n`;
    
    if (file.endsWith('.xml')) {
      combinedMarkdown += `## ${file}\n\n\`\`\`xml\n${content}\n\`\`\`\n\n`;
    } else {
      // It's a markdown file
      // Optionally we could add a heading here if the file lacks one, but usually they have it
      combinedMarkdown += `<!-- Source: ${file} -->\n\n${content}\n\n`;
    }
  } else {
    console.warn(`Warning: File not found - ${filePath}`);
  }
});

const outputMdPath = path.join(__dirname, 'Livirooms_Documentation.md');
fs.writeFileSync(outputMdPath, combinedMarkdown);
console.log(`Combined markdown saved to ${outputMdPath}`);

try {
  console.log('Generating PDF using npx md-to-pdf...');
  // Using execSync to run it synchronously
  execSync('npx -y md-to-pdf Livirooms_Documentation.md', { stdio: 'inherit', cwd: __dirname });
  console.log('PDF generation complete! -> Livirooms_Documentation.pdf');
} catch (error) {
  console.error('Failed to generate PDF:', error.message);
  process.exit(1);
}
