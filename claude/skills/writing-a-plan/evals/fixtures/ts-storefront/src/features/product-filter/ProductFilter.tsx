import { useProductFilter } from './useProductFilter'
import type { ProductFilterQuery } from './types'

export function ProductFilter({ query }: { query: ProductFilterQuery }) {
  const { data, isPending, error } = useProductFilter(query)

  if (isPending) return <output aria-live="polite">Loading…</output>
  if (error) return <p role="alert">Failed to load products.</p>

  return (
    <ul>
      {data.map((p) => (
        <li key={p.id}>{p.name}</li>
      ))}
    </ul>
  )
}
