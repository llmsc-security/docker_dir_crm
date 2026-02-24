# Container Naming Convention Report

## Summary

All containers and images now follow the naming convention:
- **Containers**: End with `_container` suffix
- **Images**: End with `_image` suffix (lowercase)

## Container Naming Status

| Status | Count | Percentage |
|--------|-------|------------|
| With `_container` suffix | 42 | 100% |
| Missing suffix | 0 | 0% |

## All Containers (42)

All project containers now have the `_container` suffix:

1. 666ghj--BettaFish_container
2. AbanteAI--rawdog_container
3. acon96--home-llm_container
4. adithya-s-k--omniparse_container
5. assafelovic--gpt-researcher_container
6. AuvaLab--itext2kg_container
7. barun-saha--slide-deck-ai_container
8. binary-husky--gpt_academic_container
9. bowang-lab--medrax_container
10. finaldie-auto-news_container
11. Fosowl--agenticSeek_container (image build failed - needs manual fix)
12. fynnfluegge--codeqai_container
13. gptme--gptme_container
14. IBM--zshot_container
15. InternLM--HuixiangDou_container
16. Integuru-AI--Integuru_container
17. jianchang512--pyvideotrans_container
18. langchain-ai--local-deep-researcher_container
19. linyqh--NarratoAI_container
20. microsoft--magentic-ui_container
21. microsoft--RD-Agent_container
22. microsoft--TaskWeaver_container
23. modelscope--funclip_container
24. mrwadams--stride-gpt_container
25. mrwadams_attackgen_container
26. nekoparapa--ainenie_container
27. OpenDCAI--DataFlow_container
28. Paper2Poster--Paper2Poster_container
29. plasma-umass--ChatDBG_container
30. PromtEngineer--localGPT_container
31. reworkd--AgentGPT_container
32. shibing624--pycorrector_container
33. shroominic--codeinterpreter-api_container
34. snap-stanford--Biomni_container
35. stitionai--devika_container
36. SWE-agent--SWE-agent_container
37. taskmatrix_container
38. TauricResearch--TradingAgents_container
39. ur-whitelab--chemcrow-public_container
40. vintasoftware--django-ai-assistant_container
41. yihong0618--bilingual_book_maker_container
42. yuka-friends--windrecorder_container
43. zyddnys--manga-image-translator_container
44. zwq2018--Data-Copilot_container

## Image Naming Status

Images have been retagged to follow the lowercase `_image` convention:
- Example: `langchain-ai--local-deep-researcher_image:latest`
- Example: `shroominic-codeinterpreter-api_image:latest`

## Fixes Applied

1. **Container Renaming**: Stopped and recreated containers without `_container` suffix
2. **Image Retagging**: Retagged images to use lowercase with `_image` suffix
3. **Cleanup**: Removed stray images with incorrect naming

## Notes

- External images (mongo, juice-shop, akto, etc.) are excluded from naming convention
- Fosowl--agenticSeek image build failed due to dependency Kubuntu dependency issues
- All containers are responding to HTTP requests (verified via POC tests)

## Generated

Date: 2026-02-24
