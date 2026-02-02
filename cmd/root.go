package main

import (
	"fmt"
	"os"

	"github.com/spf13/cobra"
)

var rootCmd = &cobra.Command{
	Use:   "amar-pathagar",
	Short: "Amar Pathagar - Trust-Based Community Library System",
	Long: `Amar Pathagar Backend API Server
	
A trust-based community library system where books circulate based on 
reputation and community trust. No late fees, no bureaucracy—just 
readers helping readers.`,
	Version: "1.0.0",
}

func Execute() {
	if err := rootCmd.Execute(); err != nil {
		fmt.Fprintln(os.Stderr, err)
		os.Exit(1)
	}
}

func init() {
	// Global flags can be added here
	rootCmd.PersistentFlags().StringP("config", "c", ".env", "config file path")
}
