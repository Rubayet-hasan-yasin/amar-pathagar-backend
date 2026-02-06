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
MIGRATIONS_DIR   = migrations

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
dev: ## Start development environment
	docker compose -f $(COMPOSE_DEV_FILE) up -d --build
	@echo "✅ Development environment started"
	@echo "📝 API: http://localhost:8080"
	@echo "📋 Logs: make logs"

.PHONY: logs
logs: ## Follow application logs
	docker compose -f $(COMPOSE_DEV_FILE) logs -f backend

.PHONY: dev-down
dev-down: ## Stop development environment
	docker compose -f $(COMPOSE_DEV_FILE) down
	@echo "✅ Development environment stopped"

# --------------------------------------------------
# Production
# --------------------------------------------------
.PHONY: prod
prod: ## Start production environment
	docker compose -f $(COMPOSE_FILE) up -d --build
	@echo "✅ Production environment started"

.PHONY: prod-down
prod-down: ## Stop production environment
	docker compose -f $(COMPOSE_FILE) down
	@echo "✅ Production environment stopped"

# --------------------------------------------------
# Database Migrations
# --------------------------------------------------
.PHONY: migrate-up
migrate-up: ## Run migrations
	docker compose -f $(COMPOSE_DEV_FILE) exec backend goose -dir $(MIGRATIONS_DIR) postgres "postgres://$(DB_USER):$(DB_PASSWORD)@postgres:5432/$(DB_NAME)?sslmode=disable" up
	@echo "✅ Migrations applied"

.PHONY: migrate-down
migrate-down: ## Roll back last migration
	docker compose -f $(COMPOSE_DEV_FILE) exec backend goose -dir $(MIGRATIONS_DIR) postgres "postgres://$(DB_USER):$(DB_PASSWORD)@postgres:5432/$(DB_NAME)?sslmode=disable" down
	@echo "✅ Migration rolled back"

.PHONY: migrate-status
migrate-status: ## Show migration status
	docker compose -f $(COMPOSE_DEV_FILE) exec backend goose -dir $(MIGRATIONS_DIR) postgres "postgres://$(DB_USER):$(DB_PASSWORD)@postgres:5432/$(DB_NAME)?sslmode=disable" status

.PHONY: migrate-create
migrate-create: ## Create new migration (usage: make migrate-create NAME=create_users)
	@if [ -z "$(NAME)" ]; then echo "❌ Usage: make migrate-create NAME=create_users"; exit 1; fi
	docker compose -f $(COMPOSE_DEV_FILE) exec backend goose -dir $(MIGRATIONS_DIR) create $(NAME) sql
	@echo "✅ Migration created in $(MIGRATIONS_DIR)/"

.PHONY: migrate-reset
migrate-reset: ## Reset all migrations and re-run
	docker compose -f $(COMPOSE_DEV_FILE) exec backend goose -dir $(MIGRATIONS_DIR) postgres "postgres://$(DB_USER):$(DB_PASSWORD)@postgres:5432/$(DB_NAME)?sslmode=disable" reset
	docker compose -f $(COMPOSE_DEV_FILE) exec backend goose -dir $(MIGRATIONS_DIR) postgres "postgres://$(DB_USER):$(DB_PASSWORD)@postgres:5432/$(DB_NAME)?sslmode=disable" up
	@echo "✅ Migrations reset and reapplied"
