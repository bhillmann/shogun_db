"""
Copyright 2015-2020 Knights Lab, Regents of the University of Minnesota.

This software is released under the GNU Affero General Public License (AGPL) v3.0 License.
"""
import os
import tarfile
from pathlib import Path
from urllib.request import urlopen
import asyncio
import aiohttp
import aiofiles



@asyncio.coroutine
def get_link(out_fp: Path, url: str) -> Path:
    """

    Args:
        output_dir:
        url:

    Returns:

    """
    out_fp.parents[0].mkdir(parents=True, exist_ok=True)
    response
    with urlopen(url) as conn:
        with open(out_fp, "wb") as outf:
            outf.writelines(conn)


def untar_ungzip_link(output_dir: Path, url: str) -> Path:
    """

    Args:
        output_dir:
        url:

    Returns:

    """
    output_dir.mkdir(parents=True, exist_ok=True)
    out_fp = output_dir / Path("taxdump.tar.gz")
    with urlopen(url) as conn:
        with open(out_fp, "wb") as outf:
            outf.writelines(conn)

    with tarfile.open(out_fp, "r:gz") as tar:
        tar.extractall(path=output_dir)

    os.remove(out_fp)
    return output_dir
