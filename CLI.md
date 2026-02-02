# Amar Pathagar CLI

The Amar Pathagar backend now includes a powerful CLI built with Cobra.

## Installation

```bash
# Build the binary
go build -o amar-pathagar ./cmd

# Or install globally
go install ./cmd
```

## Available Commands

### 1. Start REST API Server

```bash
# Using go run
go run ./cmd serve-rest

# Using built binary
./amar-pathagar serve-rest

# With custom port
./amar-pathagar serve-rest --port 9090

# With custom config
./amar-pathagar serve-rest --config /path/to/.env
```

### 2. Database Migrations

```bash
# Run all pending migrations
go run ./cmd migrate up
./amar-pathagar migrate up

# Roll back last migration
go run ./cmd migrate down
./amar-pathagar migrate down

# Show migration status
go run ./cmd migrate status
./amar-pathagar migrate status

# Reset all migrations
go run ./cmd migrate reset
./amar-pathagar migrate reset
```

### 3. Seed Database

```bash
# Create initial admin user
go run ./cmd db-seed
./amar-pathagar db-seed
```

### 4. Version Information

```bash
# Show version and build info
go run ./cmd version
./amar-pathagar version
```

### 5. Help

```bash
# Show all commands
go run ./cmd --help
./amar-pathagar --help

# Show help for specific command
go run ./cmd serve-rest --help
./amar-pathagar migrate --help
```

## Quick Start

```bash
# 1. Build the binary
go build -o amar-pathagar ./cmd

# 2. Run migrations
./amar-pathagar migrate up

# 3. Seed database
./amar-pathagar db-seed

# 4. Start server
./amar-pathagar serve-rest
```

## Development Workflow

### Using go run (no build required)

```bash
# Start server
go run ./cmd serve-rest

# Run migrations
go run ./cmd migrate up

# Seed database
go run ./cmd db-seed

# Check version
go run ./cmd version
```

### Using built binary

```bash
# Build once
go build -o amar-pathagar ./cmd

# Then use the binary
./amar-pathagar serve-rest
./amar-pathagar migrate up
./amar-pathagar db-seed
```

## Command Examples

### Start server with custom settings

```bash
# Custom port
go run ./cmd serve-rest --port 9090

# Custom config file
go run ./cmd serve-rest --config production.env

# Both
go run ./cmd serve-rest --port 9090 --config production.env
```

### Migration workflow

```bash
# Check current status
go run ./cmd migrate status

# Run migrations
go run ./cmd migrate up

# If something goes wrong, rollback
go run ./cmd migrate down

# Start fresh (WARNING: deletes all data)
go run ./cmd migrate reset
go run ./cmd migrate up
```

### Complete setup from scratch

```bash
# 1. Install dependencies
go mod download

# 2. Run migrations
go run ./cmd migrate up

# 3. Create admin user
go run ./cmd db-seed

# 4. Start server
go run ./cmd serve-rest
```

## Global Flags

All commands support these flags:

- `--config, -c`: Path to config file (default: `.env`)
- `--help, -h`: Show help for command
- `--version, -v`: Show version information

## Environment Variables

The CLI respects all environment variables from `.env`:

- `DB_HOST`, `DB_PORT`, `DB_USER`, `DB_PASSWORD`, `DB_NAME`
- `PORT`, `GIN_MODE`
- `JWT_SECRET`
- `ADMIN_USERNAME`, `ADMIN_EMAIL`, `ADMIN_PASSWORD`, `ADMIN_FULL_NAME`
- `CORS_ALLOWED_ORIGINS`

## Makefile Integration

The Makefile has been updated to use the CLI:

```bash
# These now use the CLI internally
make run          # go run ./cmd serve-rest
make migrate-up   # go run ./cmd migrate up
make seed-local   # go run ./cmd db-seed
```

## Shell Completion

Generate shell completion scripts:

```bash
# Bash
./amar-pathagar completion bash > /etc/bash_completion.d/amar-pathagar

# Zsh
./amar-pathagar completion zsh > "${fpath[1]}/_amar-pathagar"

# Fish
./amar-pathagar completion fish > ~/.config/fish/completions/amar-pathagar.fish

# PowerShell
./amar-pathagar completion powershell > amar-pathagar.ps1
```

## Production Deployment

```bash
# Build optimized binary
CGO_ENABLED=0 GOOS=linux GOARCH=amd64 go build -ldflags="-w -s" -o amar-pathagar ./cmd

# Run migrations
./amar-pathagar migrate up

# Seed database (first time only)
./amar-pathagar db-seed

# Start server
./amar-pathagar serve-rest
```

## Troubleshooting

### Command not found

```bash
# Make sure you're in the right directory
cd ~/amar-pathagar/amar-pathagar-backend

# Or use full path
go run ./cmd serve-rest
```

### Database connection error

```bash
# Check your .env file
cat .env

# Test database connection
psql -h localhost -U library_user -d online_library

# Check if PostgreSQL is running
sudo systemctl status postgresql
```

### Migration errors

```bash
# Check migration status
go run ./cmd migrate status

# Reset and try again
go run ./cmd migrate reset
go run ./cmd migrate up
```

## Benefits of CLI

1. **Clear Commands** - Explicit command names (serve-rest, migrate, db-seed)
2. **Help System** - Built-in help for all commands
3. **Flags Support** - Easy to customize behavior
4. **Subcommands** - Organized command structure
5. **Shell Completion** - Tab completion support
6. **Version Info** - Easy to check version and build details
7. **Error Handling** - Better error messages
8. **Extensible** - Easy to add new commands

## Adding New Commands

To add a new command, create a new file in `cmd/`:

```go
// cmd/my-command.go
package main

import (
    "fmt"
    "github.com/spf13/cobra"
)

var myCmd = &cobra.Command{
    Use:   "my-command",
    Short: "Description of my command",
    RunE:  runMyCommand,
}

func init() {
    rootCmd.AddCommand(myCmd)
}

func runMyCommand(cmd *cobra.Command, args []string) error {
    fmt.Println("Running my command!")
    return nil
}
```

Then rebuild and use:

```bash
go build -o amar-pathagar ./cmd
./amar-pathagar my-command
```
