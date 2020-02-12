import asyncio
import typer
from pathlib import Path
from typing import List

import aiohttp
import aiofiles


async def download_all(
        urls: List[str],
        output_dir: Path
) -> None:
    async with aiohttp.ClientSession() as session:
        semaphore = asyncio.Semaphore(16)
        tasks = [asyncio.ensure_future(download_site(url, output_dir, session, semaphore)) for url in urls]
        await asyncio.gather(*tasks, return_exceptions=True)


async def download_site(
        url: str,
        output_dir: Path,
        session: aiohttp.ClientSession,
        semaphore: asyncio.Semaphore
):
    async with semaphore:
        async with session.get(url, timeout=None) as resp:
            if resp.status == 200:
                async with aiofiles.open(output_dir / url.replace("/", "_"), mode="wb") as f:
                    while True:
                        chunk = await resp.content.read(1024**2)
                        print(f"Received a chunk from:\t{url}")
                        if not chunk:
                            break
                        await f.write(chunk)
                        print(f"Wrote a chunk from:\t{url}")


def main(
        input_urls: Path = typer.Argument(
            ...,
            exists=True,
            file_okay=True,
            dir_okay=False,
            writable=True,
            resolve_path=True,
        ),
        output_dir: Path = typer.Argument(
            ...,
            exists=False,
            file_okay=False,
            dir_okay=True,
            writable=True,
            resolve_path=True,
        )
):
    import time
    start = time.time()
    with open(input_urls) as inf:
        urls = [line.strip() for line in inf]
    output_dir.mkdir(parents=True, exist_ok=True)

    asyncio.run(download_all(urls, output_dir))
    print(f"Time taken:\t{time.time() - start}")


if __name__ == '__main__':
    typer.run(main)
