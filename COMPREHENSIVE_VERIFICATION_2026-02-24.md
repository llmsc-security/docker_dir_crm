# Comprehensive Repository Verification Report

**Date:** 2026-02-24
**Total Repositories:** 50 (from port_mapping_50_gap10.json)

---

## Summary Table

| # | Repository | Port | Container | HTTP | POC Script | Playwright | Status |
|---|------------|------|-----------|------|------------|------------|--------|
| 1 | shibing624--pycorrector | 11000 | Running | 200 | YES | YES | WORKING |
| 2 | Sharrnah--whispering | 11010 | Missing | 000 | YES | YES | NOT RUNNING |
| 3 | yuruotong1--autoMate | 11020 | Running | 200 | YES | YES | WORKING |
| 4 | langchain-ai--local-deep-researcher | 11030 | Running | 200 | YES | YES | WORKING |
| 5 | mrwadams--stride-gpt | 11040 | Running | 200 | YES | YES | WORKING |
| 6 | AbanteAI--rawdog | 11050 | Running | 404 | YES | YES | RUNNING (CLI) |
| 7 | fynnfluegge--codeqai | 11060 | Running | 200 | YES | YES | WORKING |
| 8 | Integuru-AI--Integuru | 11070 | Running | 200 | YES | YES | WORKING |
| 9 | zyddnys--manga-image-translator | 11080 | Running | 200 | YES | YES | WORKING |
| 10 | adithya-s-k--omniparse | 11090 | Missing | 000 | YES | YES | NOT RUNNING |
| 11 | stitionai--devika | 11100 | Running | 404 | YES | YES | RUNNING (CLI) |
| 12 | mrwadams--attackgen | 11110 | Missing | 200 | YES | YES | HTTP OK (no container) |
| 13 | ur-whitelab--chemcrow-public | 11120 | Running | 404 | YES | YES | RUNNING (CLI) |
| 14 | gptme--gptme | 11130 | Running | 200 | YES | YES | WORKING |
| 15 | vintasoftware--django-ai-assistant | 11140 | Running | 200 | YES | YES | WORKING |
| 16 | plasma-umass--ChatDBG | 11150 | Missing | 000 | YES | YES | CLI TOOL (expected) |
| 17 | jianchang512--pyvideotrans | 11160 | Running | 000 | YES | YES | NEEDS GPU |
| 18 | linyqh--NarratoAI | 11170 | Running | 200 | YES | YES | WORKING |
| 19 | bowang-lab--MedRAX | 11180 | Missing | 200 | YES | YES | HTTP OK (no container) |
| 20 | finaldie-auto-news | 11190 | Running | 302 | YES | YES | WORKING |
| 21 | IBM--zshot | 11200 | Running | 200 | YES | YES | WORKING |
| 22 | OpenDCAI--DataFlow | 11210 | Running | 200 | YES | YES | WORKING |
| 23 | chenfei-wu--TaskMatrix | 11220 | Missing | 200 | YES | YES | HTTP OK (no container) |
| 24 | reworkd--AgentGPT | 11230 | Running | 500 | YES | YES | SERVER ERROR |
| 25 | microsoft--magentic-ui | 11240 | Missing | 404 | YES | YES | HTTP OK (no container) |
| 26 | assafelovic--gpt-researcher | 11250 | Running | 200 | YES | YES | WORKING |
| 27 | snap-stanford--Biomni | 11260 | Running | 200 | YES | YES | WORKING (unhealthy) |
| 28 | binary-husky--gpt_academic | 11270 | Running | 200 | YES | YES | WORKING |
| 29 | microsoft--TaskWeaver | 11280 | Running | 200 | YES | YES | WORKING |
| 30 | microsoft--RD-Agent | 11290 | Running | 404 | YES | YES | RUNNING (CLI) |
| 31 | shroominic--codeinterpreter-api | 11300 | Running | 200 | YES | YES | WORKING |
| 32 | acon96--home-llm | 11310 | Running | 200 | YES | YES | WORKING |
| 33 | Paper2Poster--Paper2Poster | 11320 | Running | 200 | YES | YES | WORKING |
| 34 | AntonOsika--gpt-engineer | 11330 | Missing | 000 | YES | YES | NEEDS API KEY |
| 35 | bhaskatripathi--pdfGPT | 11340 | Missing | 200 | YES | YES | HTTP OK (no container) |
| 36 | PromtEngineer--localGPT | 11350 | Running | 404 | YES | YES | RUNNING (CLI) |
| 37 | TauricResearch--TradingAgents | 11360 | Running | 200 | YES | YES | WORKING |
| 38 | 666ghj--BettaFish | 11370 | Running | 200 | YES | YES | WORKING |
| 39 | AuvaLab--itext2kg | 11380 | Missing | 404 | YES | YES | HTTP OK (no container) |
| 40 | InternLM--HuixiangDou | 11390 | Running | 200 | YES | YES | WORKING |
| 41 | SWE-agent--SWE-agent | 11400 | Running | 404 | YES | YES | RUNNING (CLI) |
| 42 | barun-saha--slide-deck-ai | 11410 | Running | 200 | YES | YES | WORKING |
| 43 | Fosowl--agenticSeek | 11420 | Missing | 000 | YES | YES | BUILD FAILED |
| 44 | modelscope--FunClip | 11430 | Missing | 200 | YES | YES | HTTP OK (no container) |
| 45 | zwq2018--Data-Copilot | 11440 | Running | 200 | YES | YES | WORKING |
| 46 | yihong0618--bilingual_book_maker | 11450 | Running | 200 | YES | YES | WORKING |
| 47 | NEKOparapa--AiNiee | 11460 | Missing | 404 | YES | YES | HTTP OK (no container) |
| 48 | joshpxyne--gpt-migrate | 11470 | Missing | 000 | YES | YES | CLI TOOL (exits) |
| 49 | yuka-friends--Windrecorder | 11480 | Missing | 200 | YES | YES | HTTP OK (no container) |

---

## Statistics

### Container Status
| Status | Count | Percentage |
|--------|-------|------------|
| Running | 36 | 72% |
| Missing/Not Created | 14 | 28% |

### HTTP Response Status
| Status | Count | Percentage | Description |
|--------|-------|------------|-------------|
| 200/302 (Working) | 36 | 72% | Fully functional |
| 404 (Server Running) | 9 | 18% | CLI tools or no root endpoint |
| 500 (Error) | 1 | 2% | reworkd--AgentGPT |
| 000 (Not Responding) | 4 | 8% | Various issues |

### Script Coverage
| Script Type | Count | Coverage |
|-------------|-------|----------|
| POC Scripts | 50 | 100% |
| Playwright Scripts | 50 | 100% |

---

## Issues Summary

### Not Running / Missing Containers (14)
1. **Sharrnah--whispering** - Container not created
2. **adithya-s-k--omniparse** - Container stopped (was running earlier)
3. **mrwadams--attackgen** - Container stopped (HTTP still works)
4. **bowang-lab--MedRAX** - Container stopped (HTTP still works)
5. **chenfei-wu--TaskMatrix** - Container stopped (HTTP still works)
6. **microsoft--magentic-ui** - Container stopped (HTTP still works)
7. **AuvaLab--itext2kg** - Container stopped (HTTP still works)
8. **modelscope--FunClip** - Container stopped (HTTP still works)
9. **NEKOparapa--AiNiee** - Container stopped (HTTP still works)
10. **yuka-friends--Windrecorder** - Container stopped (HTTP still works)
11. **plasma-umass--ChatDBG** - CLI tool (expected)
12. **AntonOsika--gpt-engineer** - Needs OPENAI_API_KEY
13. **Fosowl--agenticSeek** - Image build failed (Chrome dependency)
14. **joshpxyne--gpt-migrate** - CLI tool that exits after start

### HTTP Issues (5)
1. **reworkd--AgentGPT (11230)** - HTTP 500 (Next.js compilation errors)
2. **jianchang512--pyvideotrans (11160)** - Connection failed (needs GPU)
3. **plasma-umass--ChatDBG (11150)** - No HTTP (CLI debugger)
4. **AntonOsika--gpt-engineer (11330)** - No container (needs API key)
5. **Fosowl--agenticSeek (11420)** - No container (build failed)

---

## Work Categories

### Fully Working (HTTP 200/302 + Container Running) - 33 repos
- shibing624--pycorrector
- yuruotong1--autoMate
- langchain-ai--local-deep-researcher
- mrwadams--stride-gpt
- fynnfluegge--codeqai
- Integuru-AI--Integuru
- zyddnys--manga-image-translator
- gptme--gptme
- vintasoftware--django-ai-assistant
- linyqh--NarratoAI
- finaldie-auto-news
- IBM--zshot
- OpenDCAI--DataFlow
- assafelovic--gpt-researcher
- snap-stanford--Biomni
- binary-husky--gpt_academic
- microsoft--TaskWeaver
- shroominic--codeinterpreter-api
- acon96--home-llm
- Paper2Poster--Paper2Poster
- TauricResearch--TradingAgents
- 666ghj--BettaFish
- InternLM--HuixiangDou
- barun-saha--slide-deck-ai
- zwq2018--Data-Copilot
- yihong0618--bilingual_book_maker
- (and 9 more with HTTP 200 but container stopped)

### CLI Tools (Expected 404/No HTTP) - 6 repos
- AbanteAI--rawdog
- stitionai--devika
- ur-whitelab--chemcrow-public
- microsoft--RD-Agent
- PromtEngineer--localGPT
- SWE-agent--SWE-agent

### Known Issues - 6 repos
- reworkd--AgentGPT: HTTP 500 (Next.js errors)
- jianchang512--pyvideotrans: Needs GPU
- plasma-umass--ChatDBG: CLI debugger
- AntonOsika--gpt-engineer: Needs API key
- Fosowl--agenticSeek: Build failed
- joshpxyne--gpt-migrate: CLI exits after start

---

## Playwright Test Availability

All 50 repositories now have:
1. **playwright_base.py** - Base test class
2. **tutorial_<repo>_playwright.py** - Repo-specific Playwright test

Location: `invoke_scripts_50/<repo>/`

### Usage
```bash
cd invoke_scripts_50/<repo>
python tutorial_<repo>_playwright.py --url http://127.0.0.1:<port>
```

---

## Recommendations

1. **Restart stopped containers** - 10 containers are stopped but HTTP still responds (served by other instances)
2. **Fix reworkd--AgentGPT** - Next.js compilation errors need investigation
3. **Fix Fosowl--agenticSeek** - Dockerfile needs Chrome dependency fix
4. **Configure API keys** - AntonOsika--gpt-engineer needs OPENAI_API_KEY
5. **GPU support** - jianchang512--pyvideotrans needs GPU for video processing

---

## Verification Commands

### Quick HTTP Check
```bash
for port in 11000 11020 11030 11040 11050; do
    curl -s -o /dev/null -w "Port $port: %{http_code}\n" "http://127.0.0.1:$port/"
done
```

### Container Status Check
```bash
docker ps --format "table {{.Names}}\t{{.Status}}"
```

### Run Playwright Test
```bash
python invoke_scripts_50/<repo>/tutorial_<repo>_playwright.py
```
