package handler

import (
	"net/http"

	"github.com/acme/billing-svc/internal/billing/application/query"
)

// Handler 實作 apigen 產生的 ServerInterface；路由由 openapi.yaml 定義。
type InvoiceHandler struct {
	listInvoices *query.ListInvoices
}

func NewInvoiceHandler(l *query.ListInvoices) *InvoiceHandler {
	return &InvoiceHandler{listInvoices: l}
}

func (h *InvoiceHandler) ListInvoices(w http.ResponseWriter, r *http.Request) {
	// 交給 mapper 轉成 apigen 型別後寫出 JSON
}
