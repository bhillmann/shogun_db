import typer

import asyncio
import aiohttp

from shogun_db.utils import untar_ungzip_link
from shogun_db.config import NCBI_TAXONOMY_LINK, ASSEMBLY_SUMMARY_LINK


def main(
        tax_link: str = NCBI_TAXONOMY_LINK,
        assembly_link: str = ASSEMBLY_SUMMARY_LINK
):
    loop = asyncio
    typer.echo("Downloading {tax_link}")




if __name__ == "__main__":
    typer.run(main)