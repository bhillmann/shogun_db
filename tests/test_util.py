import pytest

from pathlib import Path

from shogun_db import utils


@pytest.fixture
def tar_gzip_url() -> str:
    return "ftp://ftp.ncbi.nih.gov/pub/taxonomy/taxdump.tar.gz"


def test_untar_ungzip_link(tmpdir: Path, tar_gzip_url: str):
    """

    Args:
        tmpdir:
        tar_gzip_url:

    Returns:

    """
    # download the taxonomy tree
    utils.untar_ungzip_link(tmpdir, tar_gzip_url)

    # verify the file exists
