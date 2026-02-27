# ==========================================
# Laravel Docker Template Makefile
# ==========================================

COMPOSE ?= docker compose
SERVICE ?= app

# ==========================================
# Docker lifecycle
# ==========================================

up: ## Start containers
	$(COMPOSE) up -d

build: ## Build and start containers
	$(COMPOSE) up -d --build

down: ## Stop containers
	$(COMPOSE) down

restart: ## Restart containers
	$(MAKE) down
	$(MAKE) build

rebuild: ## Full rebuild with volume reset
	$(COMPOSE) down -v --remove-orphans
	$(COMPOSE) up -d --build

ps: ## Show running containers
	$(COMPOSE) ps

logs: ## Show all logs
	$(COMPOSE) logs -f

logs-app: ## Show app logs
	$(COMPOSE) logs -f $(SERVICE)

# ==========================================
# Container access
# ==========================================

bash: ## Enter app container
	$(COMPOSE) exec $(SERVICE) bash

root: ## Enter container as root
	$(COMPOSE) exec -u root $(SERVICE) bash

# ==========================================
# Laravel bootstrap (Template mode)
# ==========================================

init: ## Create new Laravel project in ./src
	mkdir -p src
	$(COMPOSE) up -d --build
	$(COMPOSE) exec $(SERVICE) composer create-project laravel/laravel . ${LARAVEL_VERSION:-"^12.0"}
	$(COMPOSE) exec $(SERVICE) php artisan key:generate

# ==========================================
# Laravel commands
# ==========================================

artisan: ## Run artisan command (use cmd="")
	$(COMPOSE) exec $(SERVICE) php artisan $(cmd)

migrate: ## Run migrations
	$(COMPOSE) exec $(SERVICE) php artisan migrate

fresh: ## Fresh migrate with seed
	$(COMPOSE) exec $(SERVICE) php artisan migrate:fresh --seed

seed: ## Seed database
	$(COMPOSE) exec $(SERVICE) php artisan db:seed

cache-clear: ## Clear all Laravel caches
	$(COMPOSE) exec $(SERVICE) php artisan cache:clear
	$(COMPOSE) exec $(SERVICE) php artisan config:clear
	$(COMPOSE) exec $(SERVICE) php artisan route:clear
	$(COMPOSE) exec $(SERVICE) php artisan view:clear

# ==========================================
# Composer
# ==========================================

composer: ## Run composer command (use cmd="")
	$(COMPOSE) exec $(SERVICE) composer $(cmd)

install: ## Composer install
	$(COMPOSE) exec $(SERVICE) composer install

update: ## Composer update
	$(COMPOSE) exec $(SERVICE) composer update

# ==========================================
# Testing
# ==========================================

test: ## Run tests
	$(COMPOSE) exec $(SERVICE) php artisan test

# ==========================================
# Helpers
# ==========================================

php: ## Show PHP version inside container
	$(COMPOSE) exec $(SERVICE) php -v

db: ## Connect to PostgreSQL
	$(COMPOSE) exec postgres psql -U ${DB_USERNAME:-laravel} -d ${DB_DATABASE:-laravel}

# ==========================================
# Default target
# ==========================================

.DEFAULT_GOAL := help

# ==========================================
# Help
# ==========================================

help: ## Show this help
	@echo ""
	@echo "Available commands:"
	@echo ""
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | \
	awk 'BEGIN {FS = ":.*?## "}; {printf "  \033[36m%-20s\033[0m %s\n", $$1, $$2}'
	@echo ""