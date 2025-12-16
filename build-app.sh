#!/bin/bash
set -e

echo "Building App Mod Booster application..."

cd app

echo "Restoring dependencies..."
dotnet restore

echo "Building application..."
dotnet build --configuration Release

echo "Publishing application..."
dotnet publish --configuration Release --output publish

echo "Creating deployment package..."
cd publish
# Create zip with files at root level (not in a subdirectory)
zip -r ../app.zip .
cd ..

echo "✓ Build complete!"
echo "Deployment package created: app/app.zip"
