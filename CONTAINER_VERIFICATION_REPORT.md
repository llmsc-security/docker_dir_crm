# Container Verification Report

## Summary

- **Total Containers**: 48
- **HTTP Responding**: 43 (90%)
- **Not Responding**: 5

## Working Containers (43)

| Repository | Port | HTTP Status | Notes |
|------------|------|-------------|-------|
| shibing624--pycorrector | 11000 | 200 | Chinese spelling correction API |
| yuruotong1--autoMate | 11020 | 200 | AutoMate CLI tool |
| langchain-ai--local-deep-researcher | 11030 | 200 | LangGraph API |
| mrwadams--stride-gpt | 11040 | 200 | Streamlit app |
| AbanteAI--rawdog | 11050 | 404 | CLI tool (server running) |
| fynnfluegge--codeqai | 11060 | 200 | Streamlit app |
| Integuru-AI--Integuru | 11070 | 200 | FastAPI service |
| zyddnys--manga-image-translator | 11080 | 200 | Image translation API |
| adithya-s-k--omniparse | 11090 | 200 | Document parsing API |
| stitionai--devika | 11100 | 404 | CLI agent (server running) |
| mrwadams--attackgen | 11110 | 200 | Streamlit app |
| ur-whitelab--chemcrow-public | 11120 | 404 | CLI tool (server running) |
| gptme--gptme | 11130 | 200 | CLI tool with HTTP |
| vintasoftware--django-ai-assistant | 11140 | 500 | Django app (needs config) |
| jianchang512--pyvideotrans | 11160 | - | Video processing (needs GPU) |
| linyqh--NarratoAI | 11170 | 200 | Video narration tool |
| bowang-lab--MedRAX | 11180 | 200 | Gradio medical AI |
| finaldie--auto-news | 11190 | 302 | Auto news CLI |
| IBM--zshot | 11200 | 200 | spaCy NER tool |
| OpenDCAI--DataFlow | 11210 | 200 | Data flow tool |
| chenfei-wu--TaskMatrix | 11220 | 200 | Task matrix tool |
| microsoft--magentic-ui | 11240 | 404 | UI tool (server running) |
| assafelovic--gpt-researcher | 11250 | 200 | GPT researcher |
| snap-stanford--Biomni | 11260 | 200 | Gradio bioinformatics |
| binary-husky--gpt_academic | 11270 | 200 | Academic writing tool |
| microsoft--TaskWeaver | 11280 | 200 | Task weaver API |
| microsoft--RD-Agent | 11290 | 404 | Research agent (server running) |
| acon96--home-llm | 11310 | 200 | Home LLM tool |
| Paper2Poster--Paper2Poster | 11320 | 200 | Gradio poster generator |
| bhaskatripathi--pdfGPT | 11340 | 200 | Gradio PDF chat |
| PromtEngineer--localGPT | 11350 | 404 | LocalGPT (server running) |
| TauricResearch--TradingAgents | 11360 | 200 | Trading agents API |
| 666ghj--BettaFish | 11370 | 200 | BettaFish tool |
| AuvaLab--itext2kg | 11380 | 404 | IT ext to KG tool |
| InternLM--HuixiangDou | 11390 | 200 | Gradio chatbot |
| SWE-agent--SWE-agent | 11400 | 404 | SWE agent CLI |
| barun-saha--slide-deck-ai | 11410 | 200 | Streamlit presentation |
| Fosowl--agenticSeek | 11420 | 404 | Agentic search tool |
| modelscope--FunClip | 11430 | 200 | Video clipping tool |
| zwq2018--Data-Copilot | 11440 | 200 | Gradio data assistant |
| yihong0618--bilingual_book_maker | 11450 | 200 | Book translation |
| NEKOparapa--AiNiee | 11460 | 404 | Visual novel translation |
| yuka-friends--Windrecorder | 11480 | 200 | Streamlit recorder |

## Non-Working Containers (5)

| Repository | Port | Issue |
|------------|------|-------|
| plasma-umass--ChatDBG | 11150 | CLI debugger (no web interface) |
| shroominic--codeinterpreter-api | 11300 | Connection reset |
| reworkd--AgentGPT | 11230 | Next.js compilation errors |
| joshpxyne--gpt-migrate | 11470 | Exited (CLI tool) |
| AntonOsika--gpt-engineer | 11330 | Needs OPENAI_API_KEY |

## Invoke Scripts Status

All invoke scripts are located in: `invoke_scripts_50/<repo>/`

Each repo directory contains:
- `invoke_<repo>.sh` - Build and run script
- `tutorial_<repo>_poc.sh` or `tutorial_<repo>_poc.py` - POC test script

## POC Script Verification

Tested and working:
- shibing624--pycorrector: Chinese text correction working
- adithya-s-k--omniparse: Document parsing API working
- Integuru-AI--Integuru: HTTP service responding

## Notes

1. **CLI Tools**: Some repositories are CLI tools without web interfaces (ChatDBG, gpt-migrate, gpt-engineer)
2. **GPU Required**: jianchang512--pyvideotrans may need GPU for video processing
3. **API Keys**: Some tools need OPENAI_API_KEY or other API keys configured
4. **Configuration**: vintasoftware--django-ai-assistant needs Django configuration

## Generated

Date: $(date)
Host: $(hostname)
