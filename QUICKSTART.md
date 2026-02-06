# Quick Start Guide - Backend

## Development

```bash
# Start development environment (with hot reload)
make dev

# View logs
make logs

# Run migrations
make migrate-up

# Stop development
make dev-down
```

The backend will be available at: http://localhost:8080

## Production

```bash
# Start production environment
make prod

# Stop production
make prod-down
```

## Migrations

```bash
# Run migrations
make migrate-up

# Check migration status
make migrate-status

# Rollback last migration
make migrate-down

# Create new migration
make migrate-create NAME=add_new_table

# Reset all migrations
make migrate-reset
```

## Environment Variables

Copy `.env.example` to `.env` and configure:

```bash
cp .env.example .env
```

Key variables:
- `DB_NAME` - Database name
- `DB_USER` - Database user
- `DB_PASSWORD` - Database password
- `JWT_SECRET` - JWT secret key
- `PORT` - Server port (default: 8080)

## Troubleshooting

**Backend exits immediately:**
- Check that `.air.toml` has `args_bin = ["serve-rest"]`
- View logs with `make logs`

**Database connection failed:**
- Ensure PostgreSQL is running: `docker ps`
- Check environment variables in `.env`
