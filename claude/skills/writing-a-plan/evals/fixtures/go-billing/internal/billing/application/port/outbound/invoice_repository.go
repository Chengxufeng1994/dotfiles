package outbound

import (
	"context"

	"github.com/acme/billing-svc/internal/billing/domain/entity"
)

type ListInvoicesCriteria struct {
	TenantID string
	Year     int
	Month    int
	Limit    int
	Offset   int
}

// InvoiceReadRepository 是查詢側的出站埠。實作在 infrastructure/persistence。
type InvoiceReadRepository interface {
	List(ctx context.Context, c ListInvoicesCriteria) ([]entity.Invoice, error)
	Count(ctx context.Context, c ListInvoicesCriteria) (int64, error)
}
