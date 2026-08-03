package mapper

import "github.com/acme/billing-svc/internal/billing/domain/entity"

// ToInvoiceResponse 把 domain entity 轉成 apigen 的對外型別。
func ToInvoiceResponse(in entity.Invoice) map[string]any {
	return map[string]any{
		"id":         in.ID,
		"number":     in.Number,
		"status":     in.Status.String(),
		"amountCent": in.AmountCent,
	}
}
