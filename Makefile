############################
# Makefile for Amar Pathagar Backend
############################

# --------------------------------------------------
# Load environment variables from .env
# --------------------------------------------------
ifneq (,$(wildcard ./.env))
    include .env
    export
endif

# --------------------------------------------------
# Configuration
# --------------------------------------------------
COMPOSE_FILE     = docker-compose.yml
COMPOSE_DEV_FILE = docker-compose.dev.yml
BINARY_NAME      = amar-pathagar-api
MAIN_PATH        = ./cmd/

.DEFAULT_GOAL := help

# --------------------------------------------------
# Help
# --------------------------------------------------
.PHONY: help
help: ## Show this help message
	@echo "╔════════════════════════════════════════════════════════════╗"
	@echo "║         Amar Pathagar Backend - Makefile Commands         ║"
	@echo "╚════════════════════════════════════════════════════════════╝"
	@echo ""
	@echo "Usage: make [target]"
	@echo ""
	@grep -hE '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | \
	awk 'BEGIN {FS = ":.*?## "}; {printf "  \033[36m%-20s\033[0m %s\n", $$1, $$2}'

# --------------------------------------------------
# Development
# --------------------------------------------------
.PHONY: dev
dev: ## Start development environment (with hot reload)
	docker compose -f $(COMPOSE_DEV_FILE) up -d
	@echo "✅ Development environment started"
	@echo "📝 API: http://localhost:8080"
	@echo "🔍 Health: http://localhost:8080/health"
	@echo "📋 Logs: make logs"

.PHONY: logs
logs: ## Follow application logs
	docker compose -f $(COMPOSE_DEV_FILE) logs -f backend

.PHONY: restart
restart: ## Restart development environment
	docker compose -f $(COMPOSE_DEV_FILE) restart backend
	@echo "✅ Backend restarted"

.PHONY: stop
stop: ## Stop development environment
	docker compose -f $(COMPOSE_DEV_FILE) stop

# --------------------------------------------------
# Production
# --------------------------------------------------
.PHONY: up
up: ## Start production environment
	docker compose -f $(COMPOSE_FILE) up -d --build
	@echo "✅ Production environment started"

.PHONY: down
down: ## Stop and remove all containers
	docker compose -f $(COMPOSE_FILE) down
	docker compose -f $(COMPOSE_DEV_FILE) down
	@echo "✅ All containers stopped and removed"

.PHONY: build
build: ## Build Docker image
	docker compose -f $(COMPOSE_FILE) build --no-cache

# --------------------------------------------------
# Database
# --------------------------------------------------
.PHONY: db-shell
db-shell: ## Open PostgreSQL shell
	docker compose -f $(COMPOSE_DEV_FILE) exec postgres psql -U $(DB_USER) -d $(DB_NAME)

.PHONY: db-reset
db-reset: ## Reset database (drop and recreate)
	@echo "⚠️  This will delete all data. Press Ctrl+C to cancel..."
	@sleep 3
	docker compose -f $(COMPOSE_DEV_FILE) exec postgres psql -U $(DB_USER) -d postgres -c "DROP DATABASE IF EXISTS $(DB_NAME);"
	docker compose -f $(COMPOSE_DEV_FILE) exec postgres psql -U $(DB_USER) -d postgres -c "CREATE DATABASE $(DB_NAME);"
	@echo "✅ Database reset complete. Run 'make migrate-up' to apply migrations."

.PHONY: db-backup
db-backup: ## Backup database
	@mkdir -p backups
	docker compose -f $(COMPOSE_DEV_FILE) exec -T postgres pg_dump -U $(DB_USER) $(DB_NAME) > backups/backup_$$(date +%Y%m%d_%H%M%S).sql
	@echo "✅ Database backed up to backups/"

.PHONY: db-restore
db-restore: ## Restore database from backup (usage: make db-restore FILE=backups/backup.sql)
	@if [ -z "$(FILE)" ]; then echo "❌ Usage: make db-restore FILE=backups/backup.sql"; exit 1; fi
	docker compose -f $(COMPOSE_DEV_FILE) exec -T postgres psql -U $(DB_USER) $(DB_NAME) < $(FILE)
	@echo "✅ Database restored from $(FILE)"

# --------------------------------------------------
# Database Migrations (Goose)
# --------------------------------------------------
MIGRATIONS_DIR = migrations
DATABASE_URL = postgres://$(DB_USER):$(DB_PASSWORD)@localhost:$(DB_PORT)/$(DB_NAME)?sslmode=disable

.PHONY: migrate-status
migrate-status: ## Show migration status
	docker compose -f $(COMPOSE_DEV_FILE) exec backend goose -dir $(MIGRATIONS_DIR) postgres "postgres://$(DB_USER):$(DB_PASSWORD)@postgres:5432/$(DB_NAME)?sslmode=disable" status

.PHONY: migrate-up
migrate-up: ## Run migrations
	docker compose -f $(COMPOSE_DEV_FILE) exec backend goose -dir $(MIGRATIONS_DIR) postgres "postgres://$(DB_USER):$(DB_PASSWORD)@postgres:5432/$(DB_NAME)?sslmode=disable" up

.PHONY: migrate-down
migrate-down: ## Roll back last migration
	docker compose -f $(COMPOSE_DEV_FILE) exec backend goose -dir $(MIGRATIONS_DIR) postgres "postgres://$(DB_USER):$(DB_PASSWORD)@postgres:5432/$(DB_NAME)?sslmode=disable" down

.PHONY: migrate-reset
migrate-reset: ## Reset and re-run migrations
	docker compose -f $(COMPOSE_DEV_FILE) exec backend goose -dir $(MIGRATIONS_DIR) postgres "postgres://$(DB_USER):$(DB_PASSWORD)@postgres:5432/$(DB_NAME)?sslmode=disable" reset
	docker compose -f $(COMPOSE_DEV_FILE) exec backend goose -dir $(MIGRATIONS_DIR) postgres "postgres://$(DB_USER):$(DB_PASSWORD)@postgres:5432/$(DB_NAME)?sslmode=disable" up

.PHONY: migration
migration: ## Create a new migration file (usage: make migration NAME=create_users)
	@if [ -z "$(NAME)" ]; then echo "❌ Usage: make migration NAME=create_users"; exit 1; fi
	docker compose -f $(COMPOSE_DEV_FILE) exec backend goose -dir $(MIGRATIONS_DIR) create $(NAME) sql
	@echo "✅ Migration created in $(MIGRATIONS_DIR)/"

# --------------------------------------------------
# Local Development (without Docker)
# --------------------------------------------------
.PHONY: run
run: ## Run locally (without Docker)
	@echo "🚀 Starting server..."
	go run ./cmd serve-rest

.PHONY: run-watch
run-watch: ## Run locally with hot reload (air)
	@echo "🚀 Starting server with hot reload..."
	air -c .air.toml

.PHONY: install
install: ## Install dependencies
	go mod download
	go mod tidy
	@echo "✅ Dependencies installed"

.PHONY: build-binary
build-binary: ## Build standalone binary
	@echo "🔨 Building binary..."
	CGO_ENABLED=0 GOOS=linux GOARCH=amd64 go build -o $(BINARY_NAME) $(MAIN_PATH)/main.go
	@echo "✅ Binary built: $(BINARY_NAME)"

# --------------------------------------------------
# Testing
# --------------------------------------------------
.PHONY: test
test: ## Run tests
	go test -v ./...

.PHONY: test-cover
test-cover: ## Run tests with coverage
	go test -v -coverprofile=coverage.out ./...
	go tool cover -html=coverage.out -o coverage.html
	@echo "✅ Coverage report: coverage.html"

.PHONY: test-race
test-race: ## Run tests with race detector
	go test -race -v ./...

# --------------------------------------------------
# Code Quality
# --------------------------------------------------
.PHONY: lint
lint: ## Run linter
	@if command -v golangci-lint > /dev/null; then \
		golangci-lint run ./...; \
	else \
		echo "⚠️  golangci-lint not installed. Install: https://golangci-lint.run/usage/install/"; \
	fi

.PHONY: fmt
fmt: ## Format code
	go fmt ./...
	@echo "✅ Code formatted"

.PHONY: vet
vet: ## Run go vet
	go vet ./...
	@echo "✅ Code vetted"

.PHONY: tidy
tidy: ## Tidy go.mod
	go mod tidy
	@echo "✅ go.mod tidied"

# --------------------------------------------------
# Docker Utilities
# --------------------------------------------------
.PHONY: ps
ps: ## Show running containers
	docker compose -f $(COMPOSE_DEV_FILE) ps

.PHONY: shell
shell: ## Open shell in backend container
	docker compose -f $(COMPOSE_DEV_FILE) exec backend sh

.PHONY: clean
clean: ## Clean up containers, volumes, and build artifacts
	docker compose -f $(COMPOSE_FILE) down -v
	docker compose -f $(COMPOSE_DEV_FILE) down -v
	rm -f $(BINARY_NAME)
	rm -f coverage.out coverage.html
	@echo "✅ Cleanup complete"

# --------------------------------------------------
# Monitoring
# --------------------------------------------------
.PHONY: stats
stats: ## Show container stats
	docker stats --no-stream

.PHONY: health
health: ## Check API health
	@curl -s http://localhost:8080/health | jq . || echo "❌ API not responding"

# --------------------------------------------------
# Database Seeding
# --------------------------------------------------
.PHONY: seed
seed: ## Seed database with initial admin user
	@echo "🌱 Seeding database..."
	docker compose -f $(COMPOSE_DEV_FILE) exec backend go run cmd/seed/main.go
	@echo "✅ Database seeded"

.PHONY: seed-local
seed-local: ## Seed database locally (without Docker)
	@echo "🌱 Seeding database..."
	go run ./cmd db-seed
	@echo "✅ Database seeded"

# --------------------------------------------------
# Quick Commands
# --------------------------------------------------
.PHONY: quick-start
quick-start: dev migrate-up seed logs ## Quick start (dev + migrate + seed + logs)

.PHONY: quick-restart
quick-restart: restart logs ## Quick restart (restart + logs)

.PHONY: quick-clean
quick-clean: down clean ## Quick clean (down + clean)

# --------------------------------------------------
# Info
# --------------------------------------------------
.PHONY: info
info: ## Show project information
	@echo "╔════════════════════════════════════════════════════════════╗"
	@echo "║              Amar Pathagar Backend Info                   ║"
	@echo "╚════════════════════════════════════════════════════════════╝"
	@echo ""
	@echo "📦 Project: Amar Pathagar Backend API"
	@echo "🔧 Language: Go $(shell go version | awk '{print $$3}')"
	@echo "🐳 Docker: $(shell docker --version | awk '{print $$3}' | tr -d ',')"
	@echo "📂 Main: $(MAIN_PATH)"
	@echo "🔨 Binary: $(BINARY_NAME)"
	@echo ""
	@echo "🌐 Endpoints:"
	@echo "   - API: http://localhost:8080"
	@echo "   - Health: http://localhost:8080/health"
	@echo "   - Database: localhost:5432"
	@echo ""
	@echo "📚 Documentation: README.md"
	@echo ""

# --------------------------------------------------
# API Documentation
# --------------------------------------------------
.PHONY: docs
docs: ## Serve API documentation (Swagger UI)
	@echo "📚 Starting Swagger UI..."
	@echo "📖 Documentation will be available at: http://localhost:8081"
	@echo ""
	@echo "Press Ctrl+C to stop the server"
	@echo ""
	@docker run -p 8081:8080 \
		-e SWAGGER_JSON=/docs/swagger.yaml \
		-v "$(PWD)/docs:/docs" \
		swaggerapi/swagger-ui

.PHONY: docs-validate
docs-validate: ## Validate OpenAPI specification
	@echo "🔍 Validating OpenAPI specification..."
	@docker run --rm -v "$(PWD)/docs:/docs" \
		openapitools/openapi-generator-cli validate \
		-i /docs/swagger.yaml && \
		echo "✅ OpenAPI specification is valid" || \
		echo "❌ OpenAPI specification has errors"

.PHONY: docs-info
docs-info: ## Show API documentation info
	@echo "╔════════════════════════════════════════════════════════════╗"
	@echo "║              API Documentation Information                 ║"
	@echo "╚════════════════════════════════════════════════════════════╝"
	@echo ""
	@echo "📄 Swagger File: docs/swagger.yaml"
	@echo "📖 README: docs/README.md"
	@echo ""
	@echo "🚀 To view documentation:"
	@echo "   make docs"
	@echo ""
	@echo "🔍 To validate specification:"
	@echo "   make docs-validate"
	@echo ""
	@echo "🌐 Online viewers:"
	@echo "   - Swagger Editor: https://editor.swagger.io/"
	@echo "   - Swagger UI: http://localhost:8081 (after running 'make docs')"
	@echo ""
