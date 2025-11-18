# Deployment Instructions for Hostinger Shared Hosting

## Prerequisites
- Hostinger shared hosting account with Git support
- Domain configured (e.g., distore.online)
- SSH access (if needed)

## Steps for Deployment

### 1. Build the project
```bash
npm run build:hostinger
```
This will:
- Build the Vue.js application
- Copy the .htaccess file to dist folder

### 2. Upload to Hostinger
**Option A - Using Git (Recommended):**
```bash
# Push your changes to GitHub
git add .
git commit -m "Ready for Hostinger deployment"
git push origin main

# Then pull on Hostinger server or use Hostinger Git integration
```

**Option B - Manual Upload:**
- Upload all contents of `dist/` folder to your domain's `public_html` folder
- Make sure `.htaccess` file is included

### 3. Verify Deployment
After deployment, these URLs should work:
- https://distore.online/ (Home/Catalog)
- https://distore.online/di-admin (Admin Products)
- https://distore.online/di-cotizaciones (Admin Orders)

## Troubleshooting

### If routes still don't work:
1. Check if `.htaccess` file is in the root directory of your domain
2. Verify that mod_rewrite is enabled on your Hostinger account
3. Contact Hostinger support if needed

### Alternative Solution (Hash Routing):
If .htaccess doesn't work, switch to hash routing:
```bash
mv src/router/index.ts src/router/index.web.ts
mv src/router/index.hash.ts src/router/index.ts
npm run build:hostinger
```
Then URLs will be:
- https://distore.online/#/di-admin
- https://distore.online/#/di-cotizaciones

## Environment Variables
Make sure to set up your environment variables in Hostinger:
- VITE_SUPABASE_URL
- VITE_SUPABASE_ANON_KEY

## File Structure in public_html
```
public_html/
├── index.html
├── .htaccess
├── assets/
│   ├── *.js
│   ├── *.css
│   └── *.svg
└── vite.svg
```
