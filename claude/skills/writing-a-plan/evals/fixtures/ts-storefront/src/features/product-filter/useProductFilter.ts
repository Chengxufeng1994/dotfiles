import { useQuery } from '@tanstack/react-query'

import { apiGet } from '../../lib/api-client'
import type { ProductFilterQuery, ProductSummary } from './types'

// 慣例：feature 資料夾內一個 use<Feature> hook 封裝 server state，元件只吃回傳值。
export function useProductFilter(query: ProductFilterQuery) {
  return useQuery({
    queryKey: ['product-filter', query],
    queryFn: () =>
      apiGet<ProductSummary[]>('/products', {
        ...(query.category ? { category: query.category } : {}),
      }),
    staleTime: 30_000,
  })
}
