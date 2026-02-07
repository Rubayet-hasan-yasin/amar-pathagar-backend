package response

import (
	"errors"
	"log"
	"net/http"

	"github.com/gin-gonic/gin"
	"github.com/yourusername/online-library/internal/domain"
)

// Success sends a successful response
func Success(c *gin.Context, data interface{}) {
	c.JSON(http.StatusOK, gin.H{
		"success": true,
		"data":    data,
	})
}

// Created sends a created response
func Created(c *gin.Context, data interface{}) {
	c.JSON(http.StatusCreated, gin.H{
		"success": true,
		"data":    data,
	})
}

// Error sends an error response
func Error(c *gin.Context, err error) {
	statusCode := http.StatusInternalServerError
	message := "internal server error"

	// Map domain errors to HTTP status codes
	switch {
	case errors.Is(err, domain.ErrNotFound), errors.Is(err, domain.ErrUserNotFound):
		statusCode = http.StatusNotFound
		message = err.Error()
	case errors.Is(err, domain.ErrInvalidCredentials), errors.Is(err, domain.ErrInvalidToken), errors.Is(err, domain.ErrTokenExpired):
		statusCode = http.StatusUnauthorized
		message = err.Error()
	case errors.Is(err, domain.ErrEmailExists), errors.Is(err, domain.ErrUsernameExists), errors.Is(err, domain.ErrAlreadyExists):
		statusCode = http.StatusConflict
		message = err.Error()
	case errors.Is(err, domain.ErrInvalidInput):
		statusCode = http.StatusBadRequest
		message = err.Error()
	case errors.Is(err, domain.ErrForbidden):
		statusCode = http.StatusForbidden
		message = err.Error()
	case errors.Is(err, domain.ErrBookNotAvailable), errors.Is(err, domain.ErrBookAlreadyBorrowed):
		statusCode = http.StatusBadRequest
		message = err.Error()
	default:
		log.Printf("Internal Server Error: %v", err)
	}

	c.JSON(statusCode, gin.H{
		"success": false,
		"error":   message,
	})
}

// BadRequest sends a bad request response
func BadRequest(c *gin.Context, message string) {
	c.JSON(http.StatusBadRequest, gin.H{
		"success": false,
		"error":   message,
	})
}

// Unauthorized sends an unauthorized response
func Unauthorized(c *gin.Context, message string) {
	c.JSON(http.StatusUnauthorized, gin.H{
		"success": false,
		"error":   message,
	})
}

// NotFound sends a not found response
func NotFound(c *gin.Context, message string) {
	c.JSON(http.StatusNotFound, gin.H{
		"success": false,
		"error":   message,
	})
}
