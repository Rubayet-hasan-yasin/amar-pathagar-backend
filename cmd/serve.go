package main

import (
	"context"
	"fmt"
	"os"
	"os/signal"
	"syscall"

	"github.com/spf13/cobra"
	"github.com/yourusername/online-library/internal/config"
	"github.com/yourusername/online-library/internal/infrastructure/logger"
	"go.uber.org/zap"
)

var serveCmd = &cobra.Command{
	Use:   "serve-rest",
	Short: "Start the REST API server",
	Long: `Start the REST API server with all endpoints.
	
This command starts the HTTP server and listens for incoming requests.
The server includes all REST API endpoints for the Amar Pathagar system.`,
	Example: `  # Start server with default settings
  amar-pathagar serve-rest
  
  # Start server with custom config
  amar-pathagar serve-rest --config /path/to/.env
  
  # Start server with custom port
  amar-pathagar serve-rest --port 9090`,
	RunE: runServe,
}

var (
	port string
)

func init() {
	rootCmd.AddCommand(serveCmd)

	// Command-specific flags
	serveCmd.Flags().StringVarP(&port, "port", "p", "", "server port (overrides config)")
}

func runServe(cmd *cobra.Command, args []string) error {
	// Load configuration
	cfg, err := config.Load()
	if err != nil {
		return fmt.Errorf("failed to load config: %w", err)
	}

	// Override port if provided via flag
	if port != "" {
		cfg.Server.Port = port
	}

	// Initialize logger
	log, err := logger.NewLogger(cfg.Server.Mode)
	if err != nil {
		return fmt.Errorf("failed to initialize logger: %w", err)
	}
	defer log.Sync()

	log.Info("🚀 Starting Amar Pathagar Backend",
		zap.String("version", "1.0.0"),
		zap.String("port", cfg.Server.Port),
		zap.String("mode", cfg.Server.Mode),
	)

	// Create context with cancellation
	ctx, stop := signal.NotifyContext(context.Background(), os.Interrupt, syscall.SIGTERM)
	defer stop()

	// Run server
	if err := run(ctx, cfg, log); err != nil {
		log.Error("server exited with error", zap.Error(err))
		return err
	}

	log.Info("✅ Server shutdown complete")
	return nil
}
