# encoding=utf-8

"""
Main module containing the PoetryDB API wrapping functions.

PoetryDB API Wrapper Functions
------------------------------

.. autosummary::
   :toctree: generated/

   get_poetry

"""

from urllib.parse import urljoin

import requests


def get_poetry(input_term, search_term=None, output=None, output_format=None, search_type=None):
    r"""
    Primary function for interfacing with the PoetryDB API.

    Parameters
    ----------
    input_term : {'author', 'title', 'lines', 'linecount'}
        The desired input term for searching PoetryDB. Must be one of or any combination of 'author',
        'title', 'lines', or 'linecount'.
    search_term : str or None, optional
        Relates to the :code:`input_term`. The search term should be relevant to the given input term.
    output : str or None, optional
        Can be any or a combination of the input terms {'author', 'title', 'lines', 'linecount'}. If None, all
        the data returned from PoetryDB by the search will be returned. The output can also be a combination of
        the terms, for example, an output of 'author,title,lines,linecount', will return the same result as if the
        parameter is set to None. An output of 'title,lines', will return the poem's title and text.
    output_format : {'json', 'text', None (default)}
        If None or 'json', the results are returned in JSON format (the PoetryDB API default). If 'text', the
        results are returned as a string with newline escapes.
    search_type : 'abs' or None (default), optional
        If None (default), the search attempts to match any part of the :code:`input_term`. If 'abs', the search
        will attempt to find an exact match when searching for the :code:`input_term`.

    Returns
    -------
    req : dict or str
        If :code:`output_format` is None or 'json', a JSON-like dict object is returned. If the specified output
        format is 'text', the result is returned as a newline escaped string.

    Examples
    --------
    >>> get_poetry('author', 'Ernest Dowson', 'author,title,linecount')
    [{'author': 'Ernest Dowson',
      'linecount': 16,
      'title': "The Moon Maiden's Song"}]
    # The following will return all of William Shakespeare's poem titles and linecounts.
    >>> r = get_poetry('author', 'William Shakespeare', 'title,linecount')
    # With the extracted information, we can easily see how many Shakespeare poems are included in the PoetryDB.
    >>> len(r)
    162
    # Using a quick and dirty loop, we can find the total number of lines written in Shakespeare's poems.
    >>> linecount = 0
    >>> for i in r:
    ...     linecount += int(i['linecount'])
    >>> linecount
    2606

    """
    uri = 'http://poetrydb.org'

    if search_type is not None and input_term != 'linecount':
        search_term = search_term + ':abs'

    if output_format is not None or output_format != '':
        if output_format not in ('json', 'text', None):
            raise ValueError("output format must be one of 'json', 'text', or None")

        if output_format is not None:
            output = output + '.' + output_format

    parameters = (input_term, search_term, output)
    parameters = [para for para in parameters if para not in {None, ''}]

    for p in parameters:
        uri = urljoin(uri, p) + '/'

    if uri[-2:] == '//':
        uri = uri[:-2]
    elif uri[-1:] == '/':
        uri = uri[:-1]

    req = requests.get(uri)

    if output_format == 'json' or output_format != 'text':
        req = req.json()
    else:
        req = req.text

    return req
