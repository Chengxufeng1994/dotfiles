package query_test

import (
	"context"
	"testing"
)

// 表格驅動測試是本專案的慣例；mock 由 mockery 產在 application/port/outbound/mocks。
func TestListInvoices_Handle(t *testing.T) {
	tests := []struct {
		name    string
		page    int
		wantErr bool
	}{
		{name: "first page", page: 1, wantErr: false},
		{name: "invalid page", page: 0, wantErr: true},
	}
	for _, tt := range tests {
		t.Run(tt.name, func(t *testing.T) {
			_ = context.Background()
			_ = tt
		})
	}
}
