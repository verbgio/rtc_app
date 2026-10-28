import 'dart:async';
import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:just_audio_background/just_audio_background.dart';
import 'package:http/http.dart' as http;
import 'package:webfeed/webfeed.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'position_store.dart';

// ============ CONFIGURAZIONE ============
const String STREAM_URL = 'https://nr12.newradio.it/stream/8744'; // <-- il tuo URL streaming reale
const String RADIO_NAME = 'RTC';

const Color BRAND_BLUE = Color.fromARGB(255, 4, 118, 248);
const Color BRAND_LIGHT_BLUE = Color.fromARGB(255, 246, 247, 248);

// Programmi podcast: aggiungi/rimuovi voci qui quando vuoi
const List<Map<String, String>> PROGRAMMI = [
  {
    'titolo': 'Alla ricerca di Maurice Ravel',
    'feed': 'https://www.retetoscanaclassica.it/feed/podcast/ricercaravel',
  },
  {
    'titolo': 'Almanaccare',
    'feed': 'https://www.retetoscanaclassica.it/feed/podcast/almanaccare',
  },
  {
    'titolo': 'Attraverso i suoni',
    'feed': 'https://www.retetoscanaclassica.it/feed/podcast/attraverso-i-suoni',
  },
  {
    'titolo': 'Auguri, Sir Paul!',
    'feed': 'https://www.retetoscanaclassica.it/feed/podcast/sir-paul',
  },
  {
    'titolo': 'Beethoven 250 – Altre composizioni',
    'feed': 'https://www.retetoscanaclassica.it/feed/podcast/beethoven250altro',
  },
  {
    'titolo': 'Beethoven 250 – I Quartetti d’archi',
    'feed': 'https://www.retetoscanaclassica.it/feed/podcast/beethoven250quartetti',
  },
  {
    'titolo': 'Beethoven 250 – Il pianoforte',
    'feed': 'https://www.retetoscanaclassica.it/feed/podcast/beethoven250piano',
  },
  {
    'titolo': 'Beethoven 250 – Le Sinfonie',
    'feed': 'https://www.retetoscanaclassica.it/feed/podcast/beethoven250sinfonie',
  },
  {
    'titolo': 'Benjamin Britten: musica per gli esseri umani',
    'feed': 'https://www.retetoscanaclassica.it/feed/podcast/brittenmusicaumani',
  },
  {
    'titolo': 'Charles Ives – I Songs, la Concord Sonata e la musica per organo',
    'feed': 'https://www.retetoscanaclassica.it/feed/podcast/charles-ives-songs-concord-organo',
  },
  {
    'titolo': 'Claudio Monteverdi: il creatore della musica moderna',
    'feed': 'https://www.retetoscanaclassica.it/feed/podcast/monteverdicreatoremusicamoderna',
  },
  {
    'titolo': 'Da George Gershwin al jazz e ritorno',
    'feed': 'https://www.retetoscanaclassica.it/feed/podcast/george-gershwin-jazz',
  },
  {
    'titolo': 'Dante in musica',
    'feed': 'https://www.retetoscanaclassica.it/feed/podcast/dantemusica',
  },
  {
    'titolo': 'David Oistrakh: una vita tra arte e politica',
    'feed': 'https://www.retetoscanaclassica.it/feed/podcast/david-oistrakh',
  },
  {
    'titolo': 'Debussy: gli scritti sulla musica',
    'feed': 'https://www.retetoscanaclassica.it/feed/podcast/debussy-musica',
  },
  {
    'titolo': 'Debussy: La Biografia',
    'feed': 'https://www.retetoscanaclassica.it/feed/podcast/debussybiografia',
  },
  {
    'titolo': 'Debussy: gli scritti sulla musica',
    'feed': 'https://www.retetoscanaclassica.it/feed/podcast/debussy-musica',
  },
  {
    'titolo': 'Dialogo della musica antica e della moderna',
    'feed': 'https://www.retetoscanaclassica.it/feed/podcast/dialogo-della-musica-antica-e-della-moderna',
  },
  {
    'titolo': 'Domenico Scarlatti',
    'feed': 'https://www.retetoscanaclassica.it/feed/podcast/domenicoscarlatti',
  },
  {
    'titolo': 'È scherzo od è follia',
    'feed': 'https://www.retetoscanaclassica.it/feed/podcast/e-scherzo-od-e-follia',
  },
  {
    'titolo': 'Eccellenti musici',
    'feed': 'https://www.retetoscanaclassica.it/feed/podcast/eccellenti-musici',
  },
  {
    'titolo': 'Ferruccio Busoni. Cultore del passato',
    'feed': 'https://www.retetoscanaclassica.it/feed/podcast/ferruccio-busoni-cultore-del-passato',
  },
  {
    'titolo': 'Filosofia con delitto.',
    'feed': 'https://www.retetoscanaclassica.it/feed/podcast/filosofia-con-delitto',
  },
  {
    'titolo': 'Gavin Bryars in Toscana',
    'feed': 'https://www.retetoscanaclassica.it/feed/podcast/bryarstoscano',
  },
  {
    'titolo': 'Gershwin: Porgy and Bess e il Song-Book del 1932',
    'feed': 'https://www.retetoscanaclassica.it/feed/podcast/gershwin-porgy-bess',
  },
  {
    'titolo': 'Giacomo Puccini: testimonianze, lettere, esecuzioni',
    'feed': 'https://www.retetoscanaclassica.it/feed/podcast/puccinitestimonianze',
  },
  {
    'titolo': 'Gioachino Rossini 150',
    'feed': 'https://www.retetoscanaclassica.it/feed/podcast/rossini150',
  },
  {
    'titolo': 'Gli antenati di Giacomo Puccini',
    'feed': 'https://www.retetoscanaclassica.it/feed/podcast/antenatipuccini',
  },
  {
    'titolo': 'Haendel: un poliglotta nell’Europa del ‘700',
    'feed': 'https://www.retetoscanaclassica.it/feed/podcast/haendelpoliglotta700',
  },
  {
    'titolo': 'Haydn musicista moderno',
    'feed': 'https://www.retetoscanaclassica.it/feed/podcast/haydnmusicistamoderno',
  },
  {
    'titolo': 'Hoffmann 250',
    'feed': 'https://www.retetoscanaclassica.it/feed/podcast/hoffmann250',
  },
  {
    'titolo': 'I 25 anni della Camerata strumentale',
    'feed': 'https://www.retetoscanaclassica.it/feed/podcast/25camp',
  },
  {
    'titolo': 'I nomi della musica: Francesco FIlidei',
    'feed': 'https://www.retetoscanaclassica.it/feed/podcast/i-nomi-della-musica-francesco-filidei',
  },
  {
    'titolo': 'Il cane da tartufi – Autori dimenticati',
    'feed': 'https://www.retetoscanaclassica.it/feed/podcast/il-cane-da-tartufi-autori-dimenticati',
  },
  {
    'titolo': 'Il Clavicembalo ben temperato. Un mito senza tempo',
    'feed': 'https://www.retetoscanaclassica.it/feed/podcast/clavicembalosenzatempo',
  },
  {
    'titolo': 'Il maestro già martellava il pianoforte – Vita e musica di Giacomo Puccini',
    'feed': 'https://www.retetoscanaclassica.it/feed/podcast/maestropuccinivita',
  },
  {
    'titolo': 'Il pianoforte ben temperato',
    'feed': 'https://www.retetoscanaclassica.it/feed/podcast/il-pianoforte-ben-temperato',
  },
  {
    'titolo': 'Il Suono dei secoli',
    'feed': 'https://www.retetoscanaclassica.it/feed/podcast/il-suono-dei-secoli',
  },
  {
    'titolo': 'Il teatro musicale di Ferruccio Busoni',
    'feed': 'https://www.retetoscanaclassica.it/feed/podcast/il-teatro-musicale-di-ferruccio-busoni',
  },
  {
    'titolo': 'L’antichità moderna di David Munrow',
    'feed': 'https://www.retetoscanaclassica.it/feed/podcast/lantichita-moderna-di-david-munrow',
  },
  {
    'titolo': 'L’occidente d’oro. Puccini e il Nuovo Mondo',
    'feed': 'https://www.retetoscanaclassica.it/feed/podcast/loccidente-doro-puccini-e-il-nuovo-mondo',
  },
  {
    'titolo': 'L’arte dei King’s Singers',
    'feed': 'https://www.retetoscanaclassica.it/feed/podcast/kingssingers',
  },
  {
    'titolo': 'L’arte invisibile',
    'feed': 'https://www.retetoscanaclassica.it/feed/podcast/arteinvisibile',
  },
  {
    'titolo': 'La musica per pianoforte di Prokof’ev',
    'feed': 'https://www.retetoscanaclassica.it/feed/podcast/pianoforteprokofev',
  },
  {
    'titolo': 'La poesia di Emily Dickinson e la musica americana del Novecento',
    'feed': 'https://www.retetoscanaclassica.it/feed/podcast/emily-dickinson',
  },
  {
    'titolo': 'La storia messa in musica',
    'feed': '	https://www.retetoscanaclassica.it/feed/podcast/la-storia-messa-in-musica-antoni-gaudi',
  },
  {
    'titolo': 'Le campane di Tosca',
    'feed': 'https://www.retetoscanaclassica.it/feed/podcast/le-campane-di-tosca',
  },
  {
    'titolo': 'Le origini del concerto pianistico',
    'feed': 'https://www.retetoscanaclassica.it/feed/podcast/concertopianistico',
  },
  {
    'titolo': 'Luce di Taglio',
    'feed': 'https://www.retetoscanaclassica.it/feed/podcast/luceditaglio',
  },
  {
    'titolo': 'Mulier Musica: Chiarina',
    'feed': 'https://www.retetoscanaclassica.it/feed/podcast/chiarinaschumann',
  },
  {
    'titolo': 'Mulier Musiche: Musica Celeste',
    'feed': 'https://www.retetoscanaclassica.it/feed/podcast/muliermusiche',
  },
  {
    'titolo': 'Music Comedies. Storia del teatro comico musicale inglese',
    'feed': 'https://www.retetoscanaclassica.it/feed/podcast/music-comedies-storia-del-teatro-comico-musicale-inglese',
  },
  {
    'titolo': 'Musica nova: voci innovative dal passato',
    'feed': 'https://www.retetoscanaclassica.it/feed/podcast/musicanova',
  },
  {
    'titolo': 'Nino Rota, cent’anni dopo',
    'feed': 'https://www.retetoscanaclassica.it/feed/podcast/nino-rota-100',
  },
  {
    'titolo': 'Notturnalia. Suoni per le ore buie',
    'feed': 'https://www.retetoscanaclassica.it/feed/podcast/notturnalia',
  },
  {
    'titolo': 'Novità in Compact',
    'feed': 'https://www.retetoscanaclassica.it/feed/podcast/novitaincompact',
  },
  {
    'titolo': 'Ombre Bianche',
    'feed': '	https://www.retetoscanaclassica.it/feed/podcast/ombrebianche',
  },
  {
    'titolo': 'Paolo Poli legge Pellegrino Artusi',
    'feed': 'https://www.retetoscanaclassica.it/feed/podcast/paolo-poli-legge-pellegrino-artusi',
  },
  {
    'titolo': 'Parliamo di Musica',
    'feed': 'https://www.retetoscanaclassica.it/feed/podcast/parliamodimusica',
  },
  {
    'titolo': 'Partiture D’Europa',
    'feed': 'https://www.retetoscanaclassica.it/feed/podcast/partitureeuropa',
  },
  {
    'titolo': 'Pensieri Urbani',
    'feed': 'https://www.retetoscanaclassica.it/feed/podcast/pensieri-urbani',
  },
  {
    'titolo': 'Per Luciano Berio',
    'feed': 'https://www.retetoscanaclassica.it/feed/podcast/per-luciano-berio',
  },
  {
    'titolo': 'Piccolo dizionario della musica classica',
    'feed': 'https://www.retetoscanaclassica.it/feed/podcast/dizionariomusicaclassica',
  },
  {
    'titolo': 'Poulenc: l’ispirazione è qualcosa di misterioso',
    'feed': 'https://www.retetoscanaclassica.it/feed/podcast/poulencispirazionemisteriosa',
  },
  {
    'titolo': 'Rachmaninov: acciaio nelle mani, oro nel cuore',
    'feed': 'https://www.retetoscanaclassica.it/feed/podcast/rachmaninovacciaio',
  },
  {
    'titolo': 'Reich – Un maestro della contemporaneità',
    'feed': 'https://www.retetoscanaclassica.it/feed/podcast/reich-un-maestro-della-contemporaneita',
  },
  {
    'titolo': 'Ricordo di Marc Blitzstein',
    'feed': 'https://www.retetoscanaclassica.it/feed/podcast/blitzstein',
  },
  {
    'titolo': 'Senti qui',
    'feed': 'https://www.retetoscanaclassica.it/feed/podcast/senti-qui',
  },
  {
    'titolo': 'Sylvano Bussotti: Vita e Teatro',
    'feed': 'https://www.retetoscanaclassica.it/feed/podcast/bussottivitaeteatro',
  },
  {
    'titolo': 'Toscana delle Culture',
    'feed': 'https://www.retetoscanaclassica.it/feed/podcast/toscanadelleculture',
  },
  {
    'titolo': 'Trame culturali',
    'feed': 'https://www.retetoscanaclassica.it/feed/podcast/trameculturali',
  },
  {
    'titolo': 'Tutto lo splendore della musica strumentale',
    'feed': 'https://www.retetoscanaclassica.it/feed/podcast/tutto-lo-splendore-della-musica-strumentale',
  },
  {
    'titolo': 'Tutto Verdi',
    'feed': 'https://www.retetoscanaclassica.it/feed/podcast/tutto-verdi',
  },
  {
    'titolo': 'Un Solennissimo Strombettio',
    'feed': 'https://www.retetoscanaclassica.it/feed/podcast/unsolennissimostrombettio',
  },
  {
    'titolo': 'Viaggio musicale nel secolo breve. Le sinfonie di Dmitrij Šostakovič',
    'feed': 'https://www.retetoscanaclassica.it/feed/podcast/viaggio-musicale-nel-secolo-breve',
  },
  {
    'titolo': 'Viaggio nel mondo di Gustav Mahler',
    'feed': 'https://www.retetoscanaclassica.it/feed/podcast/viaggio-nel-mondo-di-gustav-mahler',
  },
  {
    'titolo': 'Virtuosissime',
    'feed': 'https://www.retetoscanaclassica.it/feed/podcast/virtuosissime',
  },
];
// ========================================

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await JustAudioBackground.init(
    androidNotificationChannelId: 'it.rtc.app.channel.audio',
    androidNotificationChannelName: 'Riproduzione RTC',
    androidNotificationOngoing: true,
  );
  runApp(const RtcApp());
}

class RtcApp extends StatelessWidget {
  const RtcApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '$RADIO_NAME App',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: BRAND_BLUE,
          primary: BRAND_BLUE,
          secondary: BRAND_LIGHT_BLUE,
        ),
        useMaterial3: true,
        appBarTheme: const AppBarTheme(
          backgroundColor: BRAND_BLUE,
          foregroundColor: Colors.white,
          centerTitle: true,
        ),
        navigationBarTheme: NavigationBarThemeData(
          backgroundColor: Colors.white,
          indicatorColor: BRAND_BLUE.withValues(alpha: 0.15),
          labelTextStyle: WidgetStateProperty.all(
            const TextStyle(fontSize: 12, color: BRAND_BLUE),
          ),
          iconTheme: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.selected)) {
              return const IconThemeData(color: BRAND_BLUE);
            }
            return const IconThemeData(color: Colors.grey);
          }),
        ),
      ),
      home: const HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _index = 0;
  final _player = AudioPlayer();
  final _positionStore = PositionStore();
  String? _currentEpisodeUrl;
    Timer? _saveTimer;

  @override
  void initState() {
    super.initState();
    // Salva la posizione ogni 5 secondi durante la riproduzione
    _saveTimer = Timer.periodic(const Duration(seconds: 5), (_) {
      _saveCurrentPosition();
    });
  }

  @override
  void dispose() {
    _saveTimer?.cancel();
    _saveCurrentPosition();
    _player.dispose();
    super.dispose();
  }

  Future<void> _saveCurrentPosition() async {
    final url = _currentEpisodeUrl;
    if (url == null) return;
    final pos = _player.position;
    if (pos > Duration.zero) {
      await _positionStore.savePosition(url, pos, _player.duration);
    }
  }
  
 Future<void> _toggleLive() async {
    final isLiveCurrent = _currentEpisodeUrl == null;
    if (isLiveCurrent && _player.playing) {
      await _player.pause();
    } else {
      if (!isLiveCurrent || _player.audioSource == null) {
        _currentEpisodeUrl = null;
        await _player.stop();
        await _player.setAudioSource(
          AudioSource.uri(
            Uri.parse(STREAM_URL),
            tag: MediaItem(
              id: 'live',
              title: '$RADIO_NAME - Live',
              artist: RADIO_NAME,
            ),
          ),
        );
      }
      _player.play();
    }
    setState(() {});
  }

  Future<void> _playEpisode(Map<String, String> e) async {
    final url = e['url']!;
    final isSame = _currentEpisodeUrl == url;

    if (!isSame) {
      // Salva la posizione dell'episodio precedente prima di cambiare
      await _saveCurrentPosition();

      _currentEpisodeUrl = url;
      await _player.stop();
      await _player.setAudioSource(
        AudioSource.uri(
          Uri.parse(url),
          tag: MediaItem(
            id: url,
            title: e['titolo'] ?? 'Episodio',
            artist: RADIO_NAME,
            artUri: (e['immagine']?.isNotEmpty ?? false)
                ? Uri.parse(e['immagine']!)
                : null,
          ),
        ),
      );

      // Riprendi dalla posizione salvata, se sensata
      final saved = await _positionStore.getPosition(url);
      final total = _player.duration;
      if (saved != null && total != null) {
        final remaining = total - saved;
        // Riprendi solo se sei oltre 5s e mancano più di 30s alla fine
        if (saved > const Duration(seconds: 5) &&
            remaining > const Duration(seconds: 30)) {
          await _player.seek(saved);
        }
      }

      _player.play();
      setState(() {});
    }

    if (!mounted) return;
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => PlayerPage(
          player: _player,
          titolo: e['titolo'] ?? 'Episodio',
          descrizione: e['descrizione'] ?? '',
          immagine: e['immagine'],
          episodeUrl: url,
          positionStore: _positionStore,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final pages = [
      LivePage(
        player: _player,
        isLive: _currentEpisodeUrl == null,
        onToggle: _toggleLive,
      ),
      PodcastPage(
        player: _player,
        currentUrl: _currentEpisodeUrl,
        onPlayEpisode: _playEpisode,
      ),
    ];

    return Scaffold(
      appBar: AppBar(),
      body: pages[_index],
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        onDestinationSelected: (i) => setState(() => _index = i),
        destinations: const [
          NavigationDestination(icon: Icon(Icons.radio), label: 'Live'),
          NavigationDestination(icon: Icon(Icons.podcasts), label: 'Podcast'),
       ],
      ),
    );
  }
}

// ---------- PAGINA LIVE ----------
class LivePage extends StatelessWidget {
  final AudioPlayer player;
  final bool isLive;
  final Future<void> Function() onToggle;

  const LivePage({
    super.key,
    required this.player,
    required this.isLive,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<PlayerState>(
      stream: player.playerStateStream,
      builder: (context, snapshot) {
        final state = snapshot.data;
        final playing = isLive && (state?.playing ?? false);
        final loading = isLive &&
            (state?.processingState == ProcessingState.loading ||
                state?.processingState == ProcessingState.buffering);

        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset(
                'assets/logo.png',
                width: 180,
                height: 180,
                fit: BoxFit.contain,
              ),
              const SizedBox(height: 24),
              Text(
                '$RADIO_NAME in diretta',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      color: BRAND_BLUE,
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 40),
              if (loading)
                const CircularProgressIndicator(color: BRAND_BLUE)
              else
                IconButton.filled(
                  iconSize: 64,
                  style: IconButton.styleFrom(backgroundColor: BRAND_BLUE),
                  onPressed: onToggle,
                  icon: Icon(playing ? Icons.pause : Icons.play_arrow),
                ),
            ],
          ),
        );
      },
    );
  }
}

// ---------- PAGINA PODCAST (LISTA PROGRAMMI) ----------
// ---------- PAGINA PODCAST (LISTA PROGRAMMI CON COPERTINE) ----------
class PodcastPage extends StatefulWidget {
  final AudioPlayer player;
  final String? currentUrl;
  final Future<void> Function(Map<String, String>) onPlayEpisode;

  const PodcastPage({
    super.key,
    required this.player,
    required this.currentUrl,
    required this.onPlayEpisode,
  });

  @override
  State<PodcastPage> createState() => _PodcastPageState();
}

class _PodcastPageState extends State<PodcastPage> {
  late Future<List<_ProgrammaConCopertina>> _programmiFuture;

  @override
  void initState() {
    super.initState();
    _programmiFuture = _caricaProgrammi();
  }

  Future<List<_ProgrammaConCopertina>> _caricaProgrammi() async {
    final futures = PROGRAMMI.map((p) async {
      String? copertina;
      try {
        final response = await http.get(
          Uri.parse(p['feed']!),
          headers: {
            'User-Agent': 'RTCApp/1.0',
            'Accept': 'application/rss+xml, application/xml, text/xml',
          },
        ).timeout(const Duration(seconds: 10));
        if (response.statusCode == 200) {
          final feed = RssFeed.parse(response.body);
          copertina = feed.image?.url ?? feed.itunes?.image?.href;
        }
      } catch (_) {
        // Se il feed non risponde, mostriamo l'icona di default
      }
      return _ProgrammaConCopertina(
        titolo: p['titolo']!,
        feedUrl: p['feed']!,
        copertina: copertina,
      );
    }).toList();
    return Future.wait(futures);
  }

  Future<void> _ricarica() async {
    setState(() {
      _programmiFuture = _caricaProgrammi();
    });
    await _programmiFuture;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<_ProgrammaConCopertina>>(
      future: _programmiFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(color: BRAND_BLUE),
          );
        }

        final programmi = snapshot.data ??
            PROGRAMMI
                .map((p) => _ProgrammaConCopertina(
                      titolo: p['titolo']!,
                      feedUrl: p['feed']!,
                      copertina: null,
                    ))
                .toList();

        return RefreshIndicator(
          onRefresh: _ricarica,
          color: BRAND_BLUE,
          child: ListView.separated(
            itemCount: programmi.length,
            separatorBuilder: (_, _) => const Divider(height: 1),
            itemBuilder: (context, i) {
              final p = programmi[i];
              return ListTile(
                leading: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: p.copertina == null
                      ? Container(
                          width: 56,
                          height: 56,
                          color: BRAND_BLUE.withValues(alpha: 0.1),
                          child: const Icon(Icons.podcasts, color: BRAND_BLUE),
                        )
                      : CachedNetworkImage(
                          width: 56,
                          height: 56,
                          fit: BoxFit.cover,
                          imageUrl: p.copertina!,
                          placeholder: (_, _) => Container(
                            width: 56,
                            height: 56,
                            color: BRAND_BLUE.withValues(alpha: 0.1),
                          ),
                          errorWidget: (_, _, _) => Container(
                            width: 56,
                            height: 56,
                            color: BRAND_BLUE.withValues(alpha: 0.1),
                            child: const Icon(Icons.podcasts,
                                color: BRAND_BLUE),
                          ),
                        ),
                ),
                title: Text(
                  p.titolo,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    color: BRAND_BLUE,
                  ),
                ),
                subtitle: const Text('Apri gli episodi'),
                trailing: const Icon(Icons.chevron_right),
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => ProgrammaPage(
                        titolo: p.titolo,
                        feedUrl: p.feedUrl,
                        player: widget.player,
                        currentUrl: widget.currentUrl,
                        onPlayEpisode: widget.onPlayEpisode,
                      ),
                    ),
                  );
                },
              );
            },
          ),
        );
      },
    );
  }
}

class _ProgrammaConCopertina {
  final String titolo;
  final String feedUrl;
  final String? copertina;

  _ProgrammaConCopertina({
    required this.titolo,
    required this.feedUrl,
    this.copertina,
  });
}

// ---------- PAGINA EPISODI DI UN PROGRAMMA ----------
// ---------- PAGINA EPISODI DI UN PROGRAMMA ----------
class ProgrammaPage extends StatefulWidget {
  final String titolo;
  final String feedUrl;
  final AudioPlayer player;
  final String? currentUrl;
  final Future<void> Function(Map<String, String>) onPlayEpisode;

  const ProgrammaPage({
    super.key,
    required this.titolo,
    required this.feedUrl,
    required this.player,
    required this.currentUrl,
    required this.onPlayEpisode,
  });

  @override
  State<ProgrammaPage> createState() => _ProgrammaPageState();
}

class _FeedData {
  final String titolo;
  final String descrizione;
  final String? immagine;
  final List<Map<String, String>> episodi;

  _FeedData({
    required this.titolo,
    required this.descrizione,
    required this.immagine,
    required this.episodi,
  });
}

class _ProgrammaPageState extends State<ProgrammaPage> {
  late Future<_FeedData> _feedFuture;
  final Set<String> _descrizioniEsparse = {};
  bool _descrizioneCanaleEspansa = false;

  @override
  void initState() {
    super.initState();
    _feedFuture = _caricaFeed(widget.feedUrl);
  }

  Future<_FeedData> _caricaFeed(String feedUrl) async {
    final response = await http.get(
      Uri.parse(feedUrl),
      headers: {
        'User-Agent': 'RTCApp/1.0 (+https://www.retetoscanaclassica.it)',
        'Accept': 'application/rss+xml, application/xml, text/xml',
      },
    ).timeout(const Duration(seconds: 15));
    if (response.statusCode != 200) {
      throw Exception('Impossibile caricare il feed (${response.statusCode})');
    }

    final feed = RssFeed.parse(response.body);
    final imageCanale =
        feed.image?.url ?? feed.itunes?.image?.href ?? '';
    final items = feed.items ?? <RssItem>[];

    final episodi = items.map<Map<String, String>>((item) {
      final enclosure = item.enclosure?.url;
      final immagineEpisodio = item.itunes?.image?.href ?? imageCanale;
      return {
        'titolo': item.title ?? 'Senza titolo',
        'descrizione': _pulisciDescrizione(item.description ?? ''),
        'url': enclosure ?? '',
        'immagine': immagineEpisodio,
        'data': item.pubDate?.toString() ?? '',
      };
    }).where((e) => e['url']!.isNotEmpty).toList();

    return _FeedData(
      titolo: feed.title ?? widget.titolo,
      descrizione: _pulisciDescrizione(feed.description ?? ''),
      immagine: imageCanale.isEmpty ? null : imageCanale,
      episodi: episodi,
    );
  }

  String _pulisciDescrizione(String html) {
    return html
        .replaceAll(RegExp(r'<[^>]*>'), '')
        .replaceAll('&nbsp;', ' ')
        .replaceAll('&amp;', '&')
        .replaceAll('&quot;', '"')
        .replaceAll('&#39;', "'")
        .replaceAll('&apos;', "'")
        .replaceAll('&egrave;', 'è')
        .replaceAll('&agrave;', 'à')
        .replaceAll('&igrave;', 'ì')
        .replaceAll('&ograve;', 'ò')
        .replaceAll('&ugrave;', 'ù')
        .replaceAll(RegExp(r'\s+'), ' ')
        .trim();
  }

  Future<void> _ricarica() async {
    setState(() {
      _feedFuture = _caricaFeed(widget.feedUrl);
    });
    await _feedFuture;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.titolo)),
      body: FutureBuilder<_FeedData>(
        future: _feedFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(color: BRAND_BLUE),
            );
          }
          if (snapshot.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.error_outline, size: 48, color: Colors.red),
                    const SizedBox(height: 12),
                    Text(
                      'Errore nel caricamento degli episodi.\n${snapshot.error}',
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: _ricarica,
                      child: const Text('Riprova'),
                    ),
                  ],
                ),
              ),
            );
          }

          final feed = snapshot.data!;
          if (feed.episodi.isEmpty) {
            return const Center(child: Text('Nessun episodio disponibile'));
          }

          return RefreshIndicator(
            onRefresh: _ricarica,
            color: BRAND_BLUE,
            child: ListView(
              children: [
                _headerCanale(feed),
                const Divider(height: 1),
                ...feed.episodi.map((e) => _episodioTile(e)),
                const SizedBox(height: 16),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _headerCanale(_FeedData feed) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: (feed.immagine != null)
                    ? CachedNetworkImage(
                        imageUrl: feed.immagine!,
                        width: 96,
                        height: 96,
                        fit: BoxFit.cover,
                        placeholder: (_, _) => Container(
                          width: 96,
                          height: 96,
                          color: BRAND_BLUE.withValues(alpha: 0.1),
                        ),
                        errorWidget: (_, _, _) => Container(
                          width: 96,
                          height: 96,
                          color: BRAND_BLUE.withValues(alpha: 0.1),
                          child: const Icon(Icons.podcasts,
                              color: BRAND_BLUE),
                        ),
                      )
                    : Container(
                        width: 96,
                        height: 96,
                        color: BRAND_BLUE.withValues(alpha: 0.1),
                        child: const Icon(Icons.podcasts,
                            size: 48, color: BRAND_BLUE),
                      ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      feed.titolo,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: BRAND_BLUE,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${feed.episodi.length} episodi',
                      style: TextStyle(
                          color: Colors.grey[600], fontSize: 13),
                    ),
                  ],
                ),
              ),
            ],
          ),
          if (feed.descrizione.isNotEmpty) ...[
            const SizedBox(height: 12),
            AnimatedCrossFade(
              duration: const Duration(milliseconds: 200),
              crossFadeState: _descrizioneCanaleEspansa
                  ? CrossFadeState.showSecond
                  : CrossFadeState.showFirst,
              firstChild: Text(
                feed.descrizione,
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontSize: 14, height: 1.4),
              ),
              secondChild: Text(
                feed.descrizione,
                style: const TextStyle(fontSize: 14, height: 1.4),
              ),
            ),
            const SizedBox(height: 4),
            GestureDetector(
              onTap: () {
                setState(() {
                  _descrizioneCanaleEspansa = !_descrizioneCanaleEspansa;
                });
              },
              child: Text(
                _descrizioneCanaleEspansa ? 'Mostra meno' : 'Leggi tutto',
                style: const TextStyle(
                  color: BRAND_BLUE,
                  fontWeight: FontWeight.w600,
                  fontSize: 13,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _episodioTile(Map<String, String> e) {
    return StreamBuilder<PlayerState>(
      stream: widget.player.playerStateStream,
      builder: (context, ps) {
        final playing = ps.data?.playing ?? false;
        final processing = ps.data?.processingState;
        final isCurrent = widget.currentUrl == e['url'];
        final isPlaying = isCurrent && playing;
        final isLoading = isCurrent &&
            (processing == ProcessingState.loading ||
                processing == ProcessingState.buffering);
        final isExpanded = _descrizioniEsparse.contains(e['url']);

        return InkWell(
          onTap: () => widget.onPlayEpisode(e),
          child: Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  width: 64,
                  height: 64,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: (e['immagine']!.isEmpty)
                            ? Container(
                                width: 64,
                                height: 64,
                                color: BRAND_BLUE.withValues(alpha: 0.1),
                                child: const Icon(Icons.podcasts,
                                    color: BRAND_BLUE),
                              )
                            : CachedNetworkImage(
                                width: 64,
                                height: 64,
                                fit: BoxFit.cover,
                                imageUrl: e['immagine']!,
                                placeholder: (_, _) => Container(
                                  width: 64,
                                  height: 64,
                                  color:
                                      BRAND_BLUE.withValues(alpha: 0.1),
                                ),
                                errorWidget: (_, _, _) => Container(
                                  width: 64,
                                  height: 64,
                                  color:
                                      BRAND_BLUE.withValues(alpha: 0.1),
                                  child: const Icon(Icons.podcasts,
                                      color: BRAND_BLUE),
                                ),
                              ),
                      ),
                      Container(
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.55),
                          shape: BoxShape.circle,
                        ),
                        child: isLoading
                            ? const Padding(
                                padding: EdgeInsets.all(8),
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                            : Icon(
                                isPlaying
                                    ? Icons.pause
                                    : Icons.play_arrow,
                                color: Colors.white,
                                size: 22,
                              ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        e['titolo']!,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontWeight: isCurrent
                              ? FontWeight.bold
                              : FontWeight.w600,
                          color: BRAND_BLUE,
                          fontSize: 14,
                        ),
                      ),
                      if (e['descrizione']!.isNotEmpty) ...[
                        const SizedBox(height: 4),
                        Text(
                          e['descrizione']!,
                          maxLines: isExpanded ? null : 2,
                          overflow: isExpanded
                              ? null
                              : TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 12.5,
                            height: 1.35,
                            color: Colors.grey[700],
                          ),
                        ),
                        if (e['descrizione']!.length > 120)
                          GestureDetector(
                            onTap: () {
                              setState(() {
                                if (isExpanded) {
                                  _descrizioniEsparse.remove(e['url']);
                                } else {
                                  _descrizioniEsparse.add(e['url']!);
                                }
                              });
                            },
                            child: Padding(
                              padding: const EdgeInsets.only(top: 4),
                              child: Text(
                                isExpanded
                                    ? 'Mostra meno'
                                    : 'Leggi tutto',
                                style: const TextStyle(
                                  color: BRAND_BLUE,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                          ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

// ---------- PAGINA DI RIPRODUZIONE EPISODIO ----------
// ---------- PAGINA DI RIPRODUZIONE EPISODIO ----------
class PlayerPage extends StatefulWidget {
  final AudioPlayer player;
  final String titolo;
  final String descrizione;
  final String? immagine;
  final String episodeUrl;
  final PositionStore positionStore;

  const PlayerPage({
    super.key,
    required this.player,
    required this.titolo,
    required this.descrizione,
    required this.immagine,
    required this.episodeUrl,
    required this.positionStore,
  });

  @override
  State<PlayerPage> createState() => _PlayerPageState();
}

class _PlayerPageState extends State<PlayerPage> {
  StreamSubscription<ProcessingState>? _stateSub;
  bool _descrizioneEspansa = false;

  @override
  void initState() {
    super.initState();
    _stateSub = widget.player.processingStateStream.listen((state) {
      if (state == ProcessingState.completed) {
        widget.positionStore.clear(widget.episodeUrl);
        widget.player.seek(Duration.zero);
        widget.player.pause();
      }
    });
  }

  @override
  void dispose() {
    final pos = widget.player.position;
    if (pos > Duration.zero) {
      widget.positionStore.savePosition(
        widget.episodeUrl,
        pos,
        widget.player.duration,
      );
    }
    _stateSub?.cancel();
    super.dispose();
  }

  void _seekRelative(int seconds) {
    final pos = widget.player.position + Duration(seconds: seconds);
    final dur = widget.player.duration ?? Duration.zero;
    Duration clamped;
    if (pos < Duration.zero) {
      clamped = Duration.zero;
    } else if (dur > Duration.zero && pos > dur) {
      clamped = dur;
    } else {
      clamped = pos;
    }
    widget.player.seek(clamped);
  }

  String _fmt(Duration d) {
    final h = d.inHours;
    final m = d.inMinutes.remainder(60).toString().padLeft(2, '0');
    final s = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    if (h > 0) return '${h.toString().padLeft(2, '0')}:$m:$s';
    return '$m:$s';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('In riproduzione')),
      body: Column(
        children: [
          // ===== PARTE SUPERIORE SCROLLABILE =====
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(24, 16, 24, 8),
              child: Column(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: (widget.immagine != null &&
                            widget.immagine!.isNotEmpty)
                        ? CachedNetworkImage(
                            imageUrl: widget.immagine!,
                            width: 220,
                            height: 220,
                            fit: BoxFit.cover,
                            placeholder: (_, _) => Container(
                              width: 220,
                              height: 220,
                              color: BRAND_BLUE.withValues(alpha: 0.1),
                            ),
                            errorWidget: (_, _, _) => Container(
                              width: 220,
                              height: 220,
                              color: BRAND_BLUE.withValues(alpha: 0.1),
                              child: const Icon(Icons.podcasts,
                                  size: 80, color: BRAND_BLUE),
                            ),
                          )
                        : Container(
                            width: 220,
                            height: 220,
                            color: BRAND_BLUE.withValues(alpha: 0.1),
                            child: const Icon(Icons.podcasts,
                                size: 80, color: BRAND_BLUE),
                          ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    widget.titolo,
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          color: BRAND_BLUE,
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  if (widget.descrizione.isNotEmpty) ...[
                    const SizedBox(height: 12),
                    AnimatedCrossFade(
                      duration: const Duration(milliseconds: 200),
                      crossFadeState: _descrizioneEspansa
                          ? CrossFadeState.showSecond
                          : CrossFadeState.showFirst,
                      firstChild: Text(
                        widget.descrizione,
                        textAlign: TextAlign.center,
                        maxLines: 4,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 13.5,
                          height: 1.45,
                        ),
                      ),
                      secondChild: Text(
                        widget.descrizione,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 13.5,
                          height: 1.45,
                        ),
                      ),
                    ),
                    if (widget.descrizione.length > 180)
                      GestureDetector(
                        onTap: () {
                          setState(() {
                            _descrizioneEspansa = !_descrizioneEspansa;
                          });
                        },
                        child: Padding(
                          padding: const EdgeInsets.only(top: 6),
                          child: Text(
                            _descrizioneEspansa
                                ? 'Mostra meno'
                                : 'Leggi tutto',
                            style: const TextStyle(
                              color: BRAND_BLUE,
                              fontWeight: FontWeight.w600,
                              fontSize: 13,
                            ),
                          ),
                        ),
                      ),
                  ],
                  const SizedBox(height: 8),
                ],
              ),
            ),
          ),

          // ===== CONTROLLI FISSI IN BASSO =====
          Container(
            padding: const EdgeInsets.fromLTRB(24, 8, 24, 20),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 8,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                StreamBuilder<Duration>(
                  stream: widget.player.positionStream,
                  builder: (context, posSnap) {
                    final position = posSnap.data ?? Duration.zero;
                    return StreamBuilder<Duration?>(
                      stream: widget.player.durationStream,
                      builder: (context, durSnap) {
                        final duration = durSnap.data ?? Duration.zero;
                        final maxMs = duration.inMilliseconds.toDouble();
                        final valueMs = position.inMilliseconds
                            .toDouble()
                            .clamp(0.0, maxMs > 0 ? maxMs : 1.0);
                        return Column(
                          children: [
                            SliderTheme(
                              data: SliderTheme.of(context).copyWith(
                                activeTrackColor: BRAND_BLUE,
                                thumbColor: BRAND_BLUE,
                                inactiveTrackColor:
                                    BRAND_BLUE.withValues(alpha: 0.2),
                                overlayColor:
                                    BRAND_BLUE.withValues(alpha: 0.15),
                              ),
                              child: Slider(
                                value: valueMs.toDouble(),
                                max: maxMs > 0 ? maxMs : 1,
                                onChanged: (v) {
                                  widget.player.seek(
                                      Duration(milliseconds: v.toInt()));
                                },
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(_fmt(position),
                                      style: const TextStyle(
                                          color: BRAND_BLUE,
                                          fontSize: 12)),
                                  Text(_fmt(duration),
                                      style: const TextStyle(
                                          color: BRAND_BLUE,
                                          fontSize: 12)),
                                ],
                              ),
                            ),
                          ],
                        );
                      },
                    );
                  },
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    IconButton(
                      iconSize: 40,
                      color: BRAND_BLUE,
                      onPressed: () => _seekRelative(-10),
                      icon: const Icon(Icons.replay_10),
                    ),
                    StreamBuilder<PlayerState>(
                      stream: widget.player.playerStateStream,
                      builder: (context, snap) {
                        final state = snap.data;
                        final playing = state?.playing ?? false;
                        final loading = state?.processingState ==
                                ProcessingState.loading ||
                            state?.processingState ==
                                ProcessingState.buffering;
                        if (loading) {
                          return const SizedBox(
                            width: 64,
                            height: 64,
                            child: Padding(
                              padding: EdgeInsets.all(12),
                              child: CircularProgressIndicator(
                                  color: BRAND_BLUE),
                            ),
                          );
                        }
                        return IconButton.filled(
                          iconSize: 64,
                          style: IconButton.styleFrom(
                              backgroundColor: BRAND_BLUE),
                          onPressed: () {
                            if (playing) {
                              widget.player.pause();
                            } else {
                              widget.player.play();
                            }
                          },
                          icon: Icon(
                              playing ? Icons.pause : Icons.play_arrow),
                        );
                      },
                    ),
                    IconButton(
                      iconSize: 40,
                      color: BRAND_BLUE,
                      onPressed: () => _seekRelative(30),
                      icon: const Icon(Icons.forward_30),
                    ),
                  ],
                ),
                // Pulsante "Ricomincia da capo" più compatto
                TextButton.icon(
                  onPressed: () async {
                    await widget.player.seek(Duration.zero);
                    await widget.positionStore.clear(widget.episodeUrl);
                  },
                  icon: const Icon(Icons.restart_alt,
                      color: BRAND_BLUE, size: 18),
                  label: const Text(
                    'Ricomincia da capo',
                    style: TextStyle(color: BRAND_BLUE, fontSize: 12),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}