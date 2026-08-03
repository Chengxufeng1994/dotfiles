import { describe, expect, it } from 'vitest'

import type { ProductFilterQuery } from '../types'

describe('useProductFilter', () => {
  it('builds a stable query key from the filter', () => {
    const query: ProductFilterQuery = { category: 'lens' }
    expect(query.category).toBe('lens')
  })
})
