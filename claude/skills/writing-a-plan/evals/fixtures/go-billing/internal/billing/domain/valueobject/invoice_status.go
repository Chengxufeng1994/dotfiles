package valueobject

import "errors"

// InvoiceStatus 是發票的生命週期狀態，值物件保證只會是允許的集合之一。
type InvoiceStatus string

const (
	InvoiceStatusDraft InvoiceStatus = "draft"
	InvoiceStatusIssued InvoiceStatus = "issued"
	InvoiceStatusVoid  InvoiceStatus = "void"
)

var ErrInvalidInvoiceStatus = errors.New("invalid invoice status")

func NewInvoiceStatus(s string) (InvoiceStatus, error) {
	switch InvoiceStatus(s) {
	case InvoiceStatusDraft, InvoiceStatusIssued, InvoiceStatusVoid:
		return InvoiceStatus(s), nil
	default:
		return "", ErrInvalidInvoiceStatus
	}
}

func (s InvoiceStatus) String() string { return string(s) }
