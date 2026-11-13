import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../models/movie.dart';
import '../services/omdb_api.dart';

class MovieSearchTab extends StatefulWidget {
  final OmdbApi? api;

  const MovieSearchTab({super.key, this.api});

  @override
  State<MovieSearchTab> createState() => _MovieSearchTabState();
}

class _MovieSearchTabState extends State<MovieSearchTab> {
  late OmdbApi _api;
  final TextEditingController _searchController = TextEditingController();
  Timer? _debounce;
  Future<List<Movie>>? _results;

  @override
  void initState() {
    super.initState();
    _api = widget.api ?? OmdbApi();
  }

  void _performSearch(String text) {
    _debounce?.cancel();
    final query = text.trim();
    if (query.length < 3) {
      setState(() {
        _results = null;
      });
      return;
    }
    final results = _api.search(query);
    setState(() {
      _results = results;
    });
  }

  void _onChanged(String text) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () {
      final query = text.trim();
      if (query.length < 3) {
        setState(() {
          _results = null;
        });
        return;
      }
      final results = _api.search(query);
      setState(() {
        _results = results;
      });
    });
  }

  void _copyImdbId(String imdbId) {
    Clipboard.setData(ClipboardData(text: imdbId));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Copied $imdbId to clipboard'),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: TextField(
            controller: _searchController,
            onChanged: _onChanged,
            onSubmitted: _performSearch,
            textInputAction: TextInputAction.search,
            decoration: InputDecoration(
              hintText: 'Search movies, e.g. interstellar',
              prefixIcon: IconButton(
                icon: const Icon(Icons.search),
                onPressed: () => _performSearch(_searchController.text),
              ),
              suffixIcon: _searchController.text.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear),
                      onPressed: () {
                        _searchController.clear();
                        _performSearch('');
                      },
                    )
                  : null,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 12,
              ),
            ),
          ),
        ),
        Expanded(
          child: _results == null
              ? const Center(
                  child: Text(
                    'Search for a movie (minimum 3 letters)',
                    style: TextStyle(color: Colors.grey),
                  ),
                )
              : FutureBuilder<List<Movie>>(
                  future: _results,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    if (snapshot.hasError) {
                      return Center(
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Text(
                            'Error: ${snapshot.error}',
                            textAlign: TextAlign.center,
                            style: const TextStyle(color: Colors.red),
                          ),
                        ),
                      );
                    }

                    final movies = snapshot.data ?? [];
                    if (movies.isEmpty) {
                      return const Center(
                        child: Text(
                          'Movie not found!',
                          style: TextStyle(fontSize: 16, color: Colors.grey),
                        ),
                      );
                    }

                    return ListView.separated(
                      itemCount: movies.length,
                      separatorBuilder: (context, index) =>
                          const Divider(height: 1),
                      itemBuilder: (context, index) {
                        final movie = movies[index];
                        return ListTile(
                          leading: SizedBox(
                            width: 48,
                            height: 64,
                            child: movie.poster != null
                                ? Image.network(
                                    movie.poster!,
                                    fit: BoxFit.cover,
                                    webHtmlElementStrategy:
                                        WebHtmlElementStrategy.fallback,
                                    errorBuilder: (
                                      context,
                                      error,
                                      stackTrace,
                                    ) => const Icon(Icons.movie, size: 36),
                                  )
                                : const Icon(Icons.movie, size: 36),
                          ),
                          title: Text(
                            movie.title,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          subtitle: Text(movie.year),
                          trailing: IconButton(
                            icon: const Icon(Icons.copy_outlined),
                            tooltip: 'Copy ID: ${movie.imdbId}',
                            onPressed: () => _copyImdbId(movie.imdbId),
                          ),
                        );
                      },
                    );
                  },
                ),
        ),
      ],
    );
  }
}
