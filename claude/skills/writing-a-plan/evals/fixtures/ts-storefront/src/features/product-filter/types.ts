export type ProductFilterQuery = {
  category?: string
  minPrice?: number
  maxPrice?: number
}

export type ProductSummary = {
  id: string
  name: string
  priceCent: number
}
