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
        def is_within_directory(directory, target):
            
            abs_directory = os.path.abspath(directory)
            abs_target = os.path.abspath(target)
        
            prefix = os.path.commonprefix([abs_directory, abs_target])
            
            return prefix == abs_directory
        
        def safe_extract(tar, path=".", members=None, *, numeric_owner=False):
        
            for member in tar.getmembers():
                member_path = os.path.join(path, member.name)
                if not is_within_directory(path, member_path):
                    raise Exception("Attempted Path Traversal in Tar File")
        
            tar.extractall(path, members, numeric_owner=numeric_owner) 
            
        
        safe_extract(tar, path=output_dir)

    os.remove(out_fp)
    return output_dir
