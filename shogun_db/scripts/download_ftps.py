import asyncio
import typer
from pathlib import Path
from typing import Tuple, List


import aioftp
import aiofiles

from async_timeout import timeout


def extract_ftp_domain_path(ftp: str) -> Tuple[str, Path]:
    tail = ftp.split("//")[1]
    host = tail.split("/")[0]
    path = Path("/".join(tail.split("/")[1:]))
    return host, path


async def download_all(
        ftps: List[str],
        output_dir: Path
) -> None:
    semaphore = asyncio.Semaphore(16)
    parsed_ftps = [extract_ftp_domain_path(ftp) for ftp in ftps if ftp.startswith("ftp")]
    tasks = [asyncio.ensure_future(download_ftp(host, filename, output_dir, semaphore)) for host, filename in parsed_ftps]
    await asyncio.gather(*tasks, return_exceptions=True)


async def download_ftp(
        host: str,
        filename: Path,
        output_dir: Path,
        semaphore: asyncio.Semaphore
):
    async with semaphore:
        try:
            async with timeout(1):
                client = aioftp.Client()
                await client.connect(host)
                session = await client.login()
            print(f"started download {filename} for {host} in folder {output_dir}")
            stream = await session.download_stream(filename)
            async with aiofiles.open(output_dir / filename.name, mode="wb") as f:
                async for chunk in stream.iter_by_block():
                    await f.write(chunk)
        except asyncio.TimeoutError as e:
            print(f"timeout error {filename} for {host}")
        finally:
            client.close()
            session.close()

def main(
        input_ftps: Path = typer.Argument(
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
    with open(input_ftps) as inf:
        ftps = [line.strip() for line in inf]
    output_dir.mkdir(parents=True, exist_ok=True)

    asyncio.run(download_all(ftps, output_dir))
    print(f"Time taken:\t{time.time() - start}")


if __name__ == '__main__':
    typer.run(main)
