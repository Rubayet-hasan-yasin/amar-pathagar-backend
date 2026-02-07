package book

import (
	"context"
	"time"

	"github.com/google/uuid"
	"github.com/yourusername/online-library/internal/domain"
)

func (s *service) BatchCreate(ctx context.Context, books []*domain.Book) ([]*domain.Book, error) {
	now := time.Now()
	for _, b := range books {
		if b == nil {
			return nil, domain.ErrInvalidInput
		}
		b.ID = uuid.New().String()
		b.Status = domain.StatusAvailable
		b.CreatedAt = now
		b.UpdatedAt = now
	}

	if err := s.bookRepo.BatchCreate(ctx, books); err != nil {
		return nil, err
	}

	return books, nil
}
