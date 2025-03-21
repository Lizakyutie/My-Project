import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(debugShowCheckedModeBanner: false, home: MainPage());
  }
}

class MainPage extends StatefulWidget {
  @override
  _MainPageState createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  final PageController _pageController = PageController();
  int _selectedIndex = 0;

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
    _pageController.animateToPage(
      index,
      duration: Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PageView(
        controller: _pageController,
        physics: NeverScrollableScrollPhysics(),
        children: [NotePage(), SwipePage(), MusicPlayerPage()],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.list), label: "To-Do List"),
          BottomNavigationBarItem(icon: Icon(Icons.swipe), label: "Swipe"),
          BottomNavigationBarItem(icon: Icon(Icons.music_note), label: "Music"),
        ],
      ),
    );
  }
}

class NotePage extends StatefulWidget {
  @override
  _NotePageState createState() => _NotePageState();
}

class _NotePageState extends State<NotePage> {
  final List<Map<String, dynamic>> _notes = [];
  final TextEditingController _controller = TextEditingController();

  void _addNote() {
    if (_controller.text.isNotEmpty) {
      setState(() {
        _notes.add({"text": _controller.text, "done": false});
        _controller.clear();
      });
    }
  }

  void _toggleDone(int index) {
    setState(() {
      _notes[index]["done"] = !_notes[index]["done"];
    });
  }

  void _deleteNote(int index) {
    setState(() {
      _notes.removeAt(index);
    });
  }

  void _editNote(int index) {
    _controller.text = _notes[index]["text"];
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Edit Note"),
          content: TextField(
            controller: _controller,
            decoration: InputDecoration(hintText: "Enter new note..."),
          ),
          actions: <Widget>[
            TextButton(
              child: Text("Cancel"),
              onPressed: () => Navigator.pop(context),
            ),
            TextButton(
              child: Text("Save"),
              onPressed: () {
                setState(() {
                  _notes[index]["text"] = _controller.text;
                });
                Navigator.pop(context);
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Notes & To-Do List")),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    decoration: InputDecoration(hintText: "Enter a note..."),
                  ),
                ),
                IconButton(icon: Icon(Icons.add), onPressed: _addNote),
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: _notes.length,
              itemBuilder: (context, index) {
                return ListTile(
                  leading: Checkbox(
                    value: _notes[index]["done"],
                    onChanged: (value) => _toggleDone(index),
                  ),
                  title: Text(
                    _notes[index]["text"],
                    style: TextStyle(
                      decoration: _notes[index]["done"]
                          ? TextDecoration.lineThrough
                          : TextDecoration.none,
                    ),
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: Icon(Icons.edit),
                        onPressed: () => _editNote(index),
                      ),
                      IconButton(
                        icon: Icon(Icons.delete, color: Colors.red),
                        onPressed: () => _deleteNote(index),
                      ),
                    ],
                  ),
                  onTap: () => _editNote(index),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class SwipePage extends StatefulWidget {
  @override
  _SwipeScreenState createState() => _SwipeScreenState();
}

class _SwipeScreenState extends State<SwipePage> {
  Color bgColor = Colors.grey;

  void onSwipe(String direction) {
    setState(() {
      switch (direction) {
        case "left":
          bgColor = Colors.lightBlue;
          break;
        case "right":
          bgColor = Colors.blue;
          break;
        case "up":
          bgColor = Colors.greenAccent;
          break;
        case "down":
          bgColor = Colors.green;
          break;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Swipe Page")),
      body: GestureDetector(
        onHorizontalDragEnd: (details) {
          if (details.primaryVelocity != null) {
            onSwipe(details.primaryVelocity! < 0 ? "left" : "right");
          }
        },
        onVerticalDragEnd: (details) {
          if (details.primaryVelocity != null) {
            onSwipe(details.primaryVelocity! < 0 ? "up" : "down");
          }
        },
        child: AnimatedContainer(
          duration: Duration(milliseconds: 300),
          color: bgColor,
          child: Center(
            child: Text("Swipe Gesture Page", style: TextStyle(fontSize: 24)),
          ),
        ),
      ),
    );
  }
}

class MusicPlayerPage extends StatefulWidget {
  @override
  _MusicPlayerPageState createState() => _MusicPlayerPageState();
}

class _MusicPlayerPageState extends State<MusicPlayerPage> {
  final AudioPlayer _audioPlayer = AudioPlayer();
  bool isPlaying = false;
  int currentSongIndex = 0;
  Duration _duration = Duration.zero; // Kabuuang haba ng kanta
  Duration _position = Duration.zero; // Kasalukuyang posisyon ng kanta

  // Listahan ng mga kanta
  final List<Map<String, String>> songs = [
    {"title": "midnightRain", "file": "audio/midnightRain.mp3"},
    {"title": "", "file": "audio/WouldveCouldveShouldve.mp3"}
  ];

  @override
  void initState() {
    super.initState();

    _audioPlayer.onDurationChanged.listen((Duration d) {
      setState(() => _duration = d);
    });

    _audioPlayer.onPositionChanged.listen((Duration p) {
      setState(() => _position = p);
    });

    _audioPlayer.onPlayerComplete.listen((event) {
      _playNext();
    });
  }

  void _togglePlay() async {
    if (isPlaying) {
      await _audioPlayer.pause();
    } else {
      await _audioPlayer.play(AssetSource(songs[currentSongIndex]["file"]!));
    }
    setState(() {
      isPlaying = !isPlaying;
    });
  }

  void _playNext() {
    setState(() {
      currentSongIndex = (currentSongIndex + 1) % songs.length;
      isPlaying = false;
    });
    _togglePlay();
  }

  void _playPrevious() {
    setState(() {
      currentSongIndex = (currentSongIndex - 1) % songs.length;
      if (currentSongIndex < 0) {
        currentSongIndex = songs.length - 1;
      }
      isPlaying = false;
    });
    _togglePlay();
  }

  void _seekAudio(double value) {
    final position = Duration(seconds: value.toInt());
    _audioPlayer.seek(position);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Center(
        child: Container(
          width: 350,
          height: 300,
          decoration: BoxDecoration(
            color: Colors.grey[900],
            borderRadius: BorderRadius.circular(20),
          ),
          padding: EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                "Now Playing: ${songs[currentSongIndex]["title"]}",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              SizedBox(height: 10),

              // 🎚️ SEEKABLE SLIDER
              Slider(
                value: _position.inSeconds.toDouble(),
                min: 0,
                max: _duration.inSeconds.toDouble(),
                onChanged: (value) {
                  _seekAudio(value);
                },
                activeColor: Colors.white,
                inactiveColor: Colors.grey,
              ),

              // ⏱️ TIME LABELS (Current & Total Duration)
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "${_position.inMinutes}:${(_position.inSeconds % 60).toString().padLeft(2, '0')}",
                    style: TextStyle(color: Colors.white),
                  ),
                  Text(
                    "${_duration.inMinutes}:${(_duration.inSeconds % 60).toString().padLeft(2, '0')}",
                    style: TextStyle(color: Colors.white),
                  ),
                ],
              ),

              SizedBox(height: 10),

              // 🎵 MUSIC CONTROLS
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  IconButton(
                    icon: Icon(
                      Icons.skip_previous,
                      size: 40,
                      color: Colors.white,
                    ),
                    onPressed: _playPrevious,
                  ),
                  IconButton(
                    icon: Icon(
                      isPlaying ? Icons.pause : Icons.play_arrow,
                      size: 50,
                      color: Colors.white,
                    ),
                    onPressed: _togglePlay,
                  ),
                  IconButton(
                    icon: Icon(Icons.skip_next, size: 40, color: Colors.white),
                    onPressed: _playNext,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
