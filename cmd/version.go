package main

import (
	"fmt"
	"runtime"

	"github.com/spf13/cobra"
)

var versionCmd = &cobra.Command{
	Use:   "version",
	Short: "Print version information",
	Long:  `Display version, build information, and runtime details.`,
	Run:   runVersion,
}

func init() {
	rootCmd.AddCommand(versionCmd)
}

func runVersion(cmd *cobra.Command, args []string) {
	fmt.Println("╔════════════════════════════════════════════════════════════╗")
	fmt.Println("║         Amar Pathagar Backend - Version Info              ║")
	fmt.Println("╚════════════════════════════════════════════════════════════╝")
	fmt.Println()
	fmt.Printf("  Version:     %s\n", "1.0.0")
	fmt.Printf("  Go Version:  %s\n", runtime.Version())
	fmt.Printf("  OS/Arch:     %s/%s\n", runtime.GOOS, runtime.GOARCH)
	fmt.Printf("  Compiler:    %s\n", runtime.Compiler)
	fmt.Println()
	fmt.Println("  📚 Amar Pathagar - Trust-Based Reading Network")
	fmt.Println("  🔗 https://github.com/nesohq/amar-pathagar")
	fmt.Println()
}
