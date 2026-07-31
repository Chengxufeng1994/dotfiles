# 擷取來源內容

依資源型別選方法。目標：拿到**乾淨的全文或字幕**，並記下標題、作者／頻道、長度。

| 型別 | 主要方法 | 備援 |
| --- | --- | --- |
| 網頁 / 文章 / 部落格 | `firecrawl_scrape`（回乾淨 markdown）或 `WebFetch` | CLI：`defuddle parse <url> --md`（去廣告／導覽列，未裝：`npm i -g defuddle`） |
| YouTube 影片 | 抓字幕：`yt-dlp --skip-download --write-auto-sub --sub-lang zh,en --sub-format vtt <url>`，再讀產生的 `.vtt` | 影片描述用 `firecrawl_scrape`；或請使用者貼字幕 |
| PDF | `Read` 工具直接讀（用 `pages` 參數翻頁，超過 10 頁必填 `pages`） | 掃描型 PDF 需先 OCR |
| Google Docs / Notion / 各種文檔 | 對應 MCP，或對公開連結用 `firecrawl_scrape` | 請使用者匯出成 markdown / 貼上 |
| 已貼上的文字 | 直接使用 | — |

## 原則

- 擷取後先確認拿到的是**正文**，不是導覽列／推薦欄／留言等雜訊。
- URL 需登入或付費牆 → 停下，請使用者直接貼內容。
- 長資源（長影片、大 PDF）：先抓完整內容，再在導讀階段濃縮，不要邊抓邊丟造成遺漏。
