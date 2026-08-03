package query

import (
	"context"
	"fmt"

	"github.com/acme/billing-svc/internal/billing/application/port/outbound"
	"github.com/acme/billing-svc/internal/billing/domain/entity"
)

type ListInvoices struct {
	repo outbound.InvoiceReadRepository
}

func NewListInvoices(repo outbound.InvoiceReadRepository) *ListInvoices {
	return &ListInvoices{repo: repo}
}

type ListInvoicesQuery struct {
	TenantID string
	Year     int
	Month    int
	Page     int
	PageSize int
}

func (h *ListInvoices) Handle(ctx context.Context, q ListInvoicesQuery) ([]entity.Invoice, int64, error) {
	c := outbound.ListInvoicesCriteria{
		TenantID: q.TenantID,
		Year:     q.Year,
		Month:    q.Month,
		Limit:    q.PageSize,
		Offset:   (q.Page - 1) * q.PageSize,
	}
	items, err := h.repo.List(ctx, c)
	if err != nil {
		return nil, 0, fmt.Errorf("list invoices: %w", err)
	}
	total, err := h.repo.Count(ctx, c)
	if err != nil {
		return nil, 0, fmt.Errorf("count invoices: %w", err)
	}
	return items, total, nil
}
