package main

import (
	"context"
	"fmt"
	"os"

	"github.com/spf13/cobra"
	"github.com/yourusername/online-library/internal/config"
	"github.com/yourusername/online-library/internal/infrastructure/db/postgres"
	"github.com/yourusername/online-library/internal/repository"
	"go.uber.org/zap"
	"golang.org/x/crypto/bcrypt"
)

var dbSeedCmd = &cobra.Command{
	Use:   "db-seed",
	Short: "Seed database with initial data",
	Long:  `Create initial admin user from environment variables.`,
	RunE:  runDBSeed,
}

func init() {
	rootCmd.AddCommand(dbSeedCmd)
}

func runDBSeed(cmd *cobra.Command, args []string) error {
	fmt.Println("🌱 Seeding database...")

	// Load configuration
	cfg, err := config.Load()
	if err != nil {
		return fmt.Errorf("failed to load config: %w", err)
	}

	// Initialize logger
	logger, err := zap.NewProduction()
	if err != nil {
		return fmt.Errorf("failed to initialize logger: %w", err)
	}
	defer logger.Sync()

	// Connect to database
	conn, err := postgres.NewConnection(context.Background(), cfg.Database.ConnectionString())
	if err != nil {
		return fmt.Errorf("failed to connect to database: %w", err)
	}
	defer conn.Close()

	// Get admin credentials from environment
	adminUsername := os.Getenv("ADMIN_USERNAME")
	if adminUsername == "" {
		adminUsername = "admin"
	}

	adminEmail := os.Getenv("ADMIN_EMAIL")
	if adminEmail == "" {
		adminEmail = "admin@amarpathagar.com"
	}

	adminPassword := os.Getenv("ADMIN_PASSWORD")
	if adminPassword == "" {
		adminPassword = "admin123"
	}

	adminFullName := os.Getenv("ADMIN_FULL_NAME")
	if adminFullName == "" {
		adminFullName = "System Administrator"
	}

	// Check if admin user already exists
	userRepo := repository.NewUserRepository(conn.DB, logger)
	existingUser, err := userRepo.FindByUsername(context.Background(), adminUsername)
	if err == nil && existingUser != nil {
		fmt.Printf("✓ Admin user '%s' already exists\n", adminUsername)
		return nil
	}

	// Hash password
	hashedPassword, err := bcrypt.GenerateFromPassword([]byte(adminPassword), bcrypt.DefaultCost)
	if err != nil {
		return fmt.Errorf("failed to hash password: %w", err)
	}

	// Create admin user
	query := `
		INSERT INTO users (
			id, username, email, password_hash, full_name, role, 
			success_score, books_shared, books_received, 
			created_at, updated_at
		) VALUES (
			gen_random_uuid(), $1, $2, $3, $4, 'admin', 
			100, 0, 0, 
			NOW(), NOW()
		)
	`

	_, err = conn.DB.ExecContext(
		context.Background(),
		query,
		adminUsername,
		adminEmail,
		string(hashedPassword),
		adminFullName,
	)

	if err != nil {
		return fmt.Errorf("failed to create admin user: %w", err)
	}

	fmt.Println("✅ Admin user created successfully!")
	fmt.Printf("  Username: %s\n", adminUsername)
	fmt.Printf("  Email: %s\n", adminEmail)
	fmt.Printf("  Password: %s\n", adminPassword)
	fmt.Println("\n⚠️  IMPORTANT: Change the admin password after first login!")

	return nil
}
