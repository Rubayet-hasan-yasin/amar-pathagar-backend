package swagger

import (
	"net/http"
	"os"

	"github.com/gin-gonic/gin"
)

// ServeSwaggerYAML serves the swagger.yaml file
func ServeSwaggerYAML(c *gin.Context) {
	// Try multiple possible paths for swagger.yaml
	possiblePaths := []string{
		"docs/swagger.yaml",
		"./docs/swagger.yaml",
		"../docs/swagger.yaml",
		"amar-pathagar-backend/docs/swagger.yaml",
	}

	var data []byte
	var err error
	var foundPath string

	for _, swaggerPath := range possiblePaths {
		data, err = os.ReadFile(swaggerPath)
		if err == nil {
			foundPath = swaggerPath
			break
		}
	}

	if err != nil || foundPath == "" {
		// Get current working directory for debugging
		wd, _ := os.Getwd()
		c.JSON(http.StatusNotFound, gin.H{
			"error":             "swagger.yaml not found",
			"working_directory": wd,
			"tried_paths":       possiblePaths,
		})
		return
	}

	// Serve as YAML
	c.Data(http.StatusOK, "application/x-yaml", data)
}

// ServeSwaggerUI serves a simple HTML page with Swagger UI
func ServeSwaggerUI(c *gin.Context) {
	html := `
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Amar Pathagar API Documentation</title>
    <link rel="stylesheet" type="text/css" href="https://unpkg.com/swagger-ui-dist@5.10.5/swagger-ui.css">
    <style>
        body {
            margin: 0;
            padding: 0;
        }
    </style>
</head>
<body>
    <div id="swagger-ui"></div>
    <script src="https://unpkg.com/swagger-ui-dist@5.10.5/swagger-ui-bundle.js"></script>
    <script src="https://unpkg.com/swagger-ui-dist@5.10.5/swagger-ui-standalone-preset.js"></script>
    <script>
        window.onload = function() {
            window.ui = SwaggerUIBundle({
                url: "/docs/swagger.yaml",
                dom_id: '#swagger-ui',
                deepLinking: true,
                presets: [
                    SwaggerUIBundle.presets.apis,
                    SwaggerUIStandalonePreset
                ],
                plugins: [
                    SwaggerUIBundle.plugins.DownloadUrl
                ],
                layout: "StandaloneLayout"
            });
        };
    </script>
</body>
</html>
`
	c.Data(http.StatusOK, "text/html; charset=utf-8", []byte(html))
}
