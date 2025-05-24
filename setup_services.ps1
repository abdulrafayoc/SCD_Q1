# Script to set up Docker configuration for all services

# Define services
$services = @("Auth Service", "Profile Service", "Blog Service", "Comment Service")

# Dockerfile template
$dockerfileTemplate = @'
# Use official Node.js 16 image as base
FROM node:16-alpine

# Create app directory
WORKDIR /usr/src/app

# Copy package.json and package-lock.json
COPY package*.json ./

# Install dependencies
RUN npm install

# Copy application code
COPY . .

# Expose the port the app runs on
EXPOSE $PORT

# Command to run the application
CMD ["node", "server.js"]
'@

# .dockerignore template
$dockerIgnoreTemplate = @'
node_modules
npm-debug.log
.git
.gitignore
.env
.dockerignore
Dockerfile
docker-compose*.yml
'@

# Create Dockerfile and .dockerignore for each service
foreach ($service in $services) {
    $servicePath = ".\$service"
    
    # Create Dockerfile
    $dockerfilePath = "$servicePath\Dockerfile"
    if (-not (Test-Path $dockerfilePath)) {
        $dockerfileContent = $dockerfileTemplate -replace '\$PORT', ($service -replace '.*\s(\d+)', '$1')
        Set-Content -Path $dockerfilePath -Value $dockerfileContent
        Write-Host "Created Dockerfile for $service"
    } else {
        Write-Host "Dockerfile already exists for $service"
    }
    
    # Create .dockerignore
    $dockerIgnorePath = "$servicePath\.dockerignore"
    if (-not (Test-Path $dockerIgnorePath)) {
        Set-Content -Path $dockerIgnorePath -Value $dockerIgnoreTemplate
        Write-Host "Created .dockerignore for $service"
    } else {
        Write-Host ".dockerignore already exists for $service"
    }
}

# Create .env file if it doesn't exist
if (-not (Test-Path .\.env)) {
    Copy-Item .\.env.example -Destination .\.env
    Write-Host "Created .env file. Please update it with your configuration."
} else {
    Write-Host ".env file already exists"
}

Write-Host "`nSetup complete! Next steps:"
Write-Host "1. Edit the .env file with your configuration"
Write-Host "2. Run 'docker-compose up --build -d' to start all services"
Write-Host "3. Access the services at http://localhost:3001-3004"
