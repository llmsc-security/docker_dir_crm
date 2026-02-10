# Working HTTP Services - Committed

## Commit Date
2026-02-10

## Latest Verification
2026-02-10 - All 13 confirmed working services tested and responding with HTTP 200

## Last Verified
2026-02-10 (All 13 services responding with HTTP 200)

## Confirmed Working HTTP Services (13)

The following repositories have been verified with HTTP 200 responses:

| # | Repo | Host Port | Container Port | Status | Last Verified |
|---|------|-----------|----------------|--------|---------------|
| 1 | shibing624--pycorrector | 11000 | 5001 | Working | 2026-02-10 |
| 2 | mrwadams--stride-gpt | 11040 | 8501 | Working | 2026-02-10 |
| 3 | fynnfluegge--codeqai | 11060 | 8501 | Working | 2026-02-10 |
| 4 | Integuru-AI--Integuru | 11070 | 11070 | Working | 2026-02-10 |
| 5 | zyddnys--manga-image-translator | 11080 | 8000 | Working | 2026-02-10 |
| 6 | adithya-s-k--omniparse | 11090 | 8000 | Working | 2026-02-10 |
| 7 | mrwadams--attackgen | 11110 | 8500 | Working | 2026-02-10 |
| 8 | Paper2Poster--Paper2Poster | 11320 | 7860 | Working | 2026-02-10 |
| 9 | TauricResearch--TradingAgents | 11360 | 11360 | Working | 2026-02-10 |
| 10 | InternLM--HuixiangDou | 11390 | 7860 | Working | 2026-02-10 |
| 11 | barun-saha--slide-deck-ai | 11410 | 8501 | Working | 2026-02-10 |
| 12 | yihong0618--bilingual_book_maker | 11450 | 7860 | Working | 2026-02-10 |
| 13 | yuka-friends--Windrecorder | 11480 | 8501 | Working | 2026-02-10 |

## Service Details

### 1. shibing624--pycorrector (Port 11000)
- **Container**: shibing624--pycorrector_container
- **Image**: shibing624--pycorrector_image
- **Endpoint**: http://127.0.0.1:11000/
- **Response**: 200 OK
- **Type**: FastAPI

### 2. mrwadams--stride-gpt (Port 11040)
- **Container**: mrwadams--stride-gpt_container
- **Image**: mrwadams--stride-gpt_image
- **Endpoint**: http://127.0.0.1:11040/
- **Response**: 200 OK
- **Type**: Streamlit (healthy)

### 3. fynnfluegge--codeqai (Port 11060)
- **Container**: fynnfluegge--codeqai_container
- **Image**: fynnfluegge--codeqai_image
- **Endpoint**: http://127.0.0.1:11060/
- **Response**: 200 OK
- **Type**: Streamlit (healthy)

### 4. Integuru-AI--Integuru (Port 11070)
- **Container**: Integuru-AI--Integuru_container
- **Image**: integuru-ai-integuru_image
- **Endpoint**: http://127.0.0.1:11070/
- **Response**: 200 OK
- **Type**: Custom FastAPI

### 5. zyddnys--manga-image-translator (Port 11080)
- **Container**: zyddnys--manga-image-translator_container
- **Image**: zyddnys--manga-image-translator_image
- **Endpoint**: http://127.0.0.1:11080/
- **Response**: 200 OK
- **Type**: FastAPI

### 6. adithya-s-k--omniparse (Port 11090)
- **Container**: adithya-s-k--omniparse_container
- **Image**: adithya-s-k--omniparse_image
- **Endpoint**: http://127.0.0.1:11090/
- **Response**: 200 OK
- **Type**: FastAPI

### 7. mrwadams--attackgen (Port 11110)
- **Container**: mrwadams--attackgen_container
- **Image**: mrwadams--attackgen_image
- **Endpoint**: http://127.0.0.1:11110/
- **Response**: 200 OK
- **Type**: Streamlit (healthy)

### 8. Paper2Poster--Paper2Poster (Port 11320)
- **Container**: Paper2Poster--Paper2Poster_container
- **Image**: paper2poster-paper2poster_image
- **Endpoint**: http://127.0.0.1:11320/
- **Response**: 200 OK
- **Type**: Gradio

### 9. TauricResearch--TradingAgents (Port 11360)
- **Container**: tauricresearch--tradingagents_container
- **Image**: tauricresearch--tradingagents_image
- **Endpoint**: http://127.0.0.1:11360/
- **Response**: 200 OK
- **Type**: FastAPI

### 10. InternLM--HuixiangDou (Port 11390)
- **Container**: InternLM--HuixiangDou_container
- **Image**: internlm-huixiangdou-image
- **Endpoint**: http://127.0.0.1:11390/
- **Response**: 200 OK
- **Type**: Gradio

### 11. barun-saha--slide-deck-ai (Port 11410)
- **Container**: barun-saha--slide-deck-ai_container
- **Image**: barun-saha--slide-deck-ai_image
- **Endpoint**: http://127.0.0.1:11410/
- **Response**: 200 OK
- **Type**: Streamlit

### 12. yihong0618--bilingual_book_maker (Port 11450)
- **Container**: yihong0618--bilingual_book_maker_container
- **Image**: yihong0618--bilingual_book_maker_image
- **Endpoint**: http://127.0.0.1:11450/
- **Response**: 200 OK
- **Type**: FastAPI

### 13. yuka-friends--Windrecorder (Port 11480)
- **Container**: yuka-friends--windrecorder_container
- **Image**: yuka-friends--windrecorder_image
- **Endpoint**: http://127.0.0.1:11480/
- **Response**: 200 OK
- **Type**: Streamlit

## Summary Statistics

- **Total Confirmed Working**: 13
- **Port Range**: 11000-11480
- **Container Technologies**: Streamlit, FastAPI, Gradio

## Notes

- Port 11160 (jianchang512--pyvideotrans) - Container running but HTTP timeout
- Port 11180 (bowang-lab--MedRAX) - Container unhealthy, HTTP timeout
- Port 11030 (langchain-ai--local-deep-researcher) - Running but not responding on HTTP

## Related Files

- `/home/taicen/wangjian/os_dev_google/docker_dirs_yuelin/final_deliverable_table.md` - Full deliverable table
- `/home/taicen/wangjian/os_dev_google/docker_dirs_yuelin/build_logs/` - Build logs
- `/home/taicen/wangjian/os_dev_google/docker_dirs_yuelin/invoke_scripts_50/` - Invoke scripts
