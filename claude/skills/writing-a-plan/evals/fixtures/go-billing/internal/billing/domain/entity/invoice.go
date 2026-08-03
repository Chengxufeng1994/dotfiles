package entity

import (
	"time"

	"github.com/acme/billing-svc/internal/billing/domain/valueobject"
)

type Invoice struct {
	ID         string
	TenantID   string
	Number     string
	Status     valueobject.InvoiceStatus
	AmountCent int64
	IssuedAt   time.Time
}
