package postgres

import (
	"context"

	"gorm.io/gorm"

	"github.com/acme/billing-svc/internal/billing/application/port/outbound"
	"github.com/acme/billing-svc/internal/billing/domain/entity"
)

type InvoiceEntity struct {
	ID         string `gorm:"primaryKey;column:id"`
	TenantID   string `gorm:"column:tenant_id;index"`
	Number     string `gorm:"column:number"`
	Status     string `gorm:"column:status"`
	AmountCent int64  `gorm:"column:amount_cent"`
}

func (InvoiceEntity) TableName() string { return "invoices" }

type InvoiceReadRepository struct{ db *gorm.DB }

func NewInvoiceReadRepository(db *gorm.DB) *InvoiceReadRepository {
	return &InvoiceReadRepository{db: db}
}

func (r *InvoiceReadRepository) List(ctx context.Context, c outbound.ListInvoicesCriteria) ([]entity.Invoice, error) {
	return nil, nil
}

func (r *InvoiceReadRepository) Count(ctx context.Context, c outbound.ListInvoicesCriteria) (int64, error) {
	return 0, nil
}
