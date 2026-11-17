/// Explicit, offline fixtures. These are not fetched from a server.
abstract final class PreviewData {
  static const coordinates = '9.5942° N, 76.5221° E';
  static final sessionDate = DateTime(2026, 11, 17, 8, 0);
  static const challenges = [
    Challenge(
      'Campus Clean-up',
      'Collect 20 kg of litter',
      '5 days left',
      12.4,
      20,
      'Ongoing',
      'campus',
    ),
    Challenge(
      'Plastic-Free Week',
      'Collect 10 kg of plastic waste',
      '12 days left',
      0,
      10,
      'Ongoing',
      'plastic',
    ),
    Challenge(
      'Green City Drive',
      'Be part of the city-wide plog',
      '20 days left',
      0,
      15,
      'Ongoing',
      'city',
    ),
    Challenge(
      'Lakeside Together',
      'A fresh start for our lake',
      'Starts Nov 28',
      0,
      25,
      'Upcoming',
      'city',
    ),
    Challenge(
      'December Green Miles',
      'Walk, collect, make a difference',
      'Starts Dec 1',
      0,
      30,
      'Upcoming',
      'campus',
    ),
    Challenge(
      'First Five',
      'Your first 5 kg collected',
      'Completed Nov 10',
      5,
      5,
      'Completed',
      'plastic',
    ),
  ];
  static const cleanups = [
    Cleanup(
      'city',
      'City Lake Clean-up',
      '1.2 km',
      'Sat, Nov 21 · 8:00 AM',
      24,
      'Lakeside walking trail',
    ),
    Cleanup(
      'park',
      'Green Park Plog',
      '2.4 km',
      'Sun, Nov 22 · 7:30 AM',
      18,
      'Green Park north gate',
    ),
    Cleanup(
      'campus',
      'Campus Clean-up',
      '3.1 km',
      'Sat, Nov 28 · 8:00 AM',
      32,
      'College main entrance',
    ),
  ];
  static const ranks = [
    RankEntry('Rohit S.', 28.4, 8.2, 142.8, 0),
    RankEntry('Ananya P.', 25.1, 7.6, 128.3, 1),
    RankEntry('Karthik R.', 22.6, 6.1, 110.5, 2),
    RankEntry('You', 12.4, 4.2, 68.4, 3),
    RankEntry('Meghana V.', 11.8, 3.8, 72.1, 4),
    RankEntry('Siddharth K.', 10.9, 3.1, 59.7, 5),
  ];
}

class Challenge {
  const Challenge(
    this.name,
    this.description,
    this.time,
    this.progress,
    this.goal,
    this.status,
    this.art,
  );
  final String name, description, time, status, art;
  final double progress, goal;
}

class Cleanup {
  const Cleanup(
    this.id,
    this.name,
    this.distance,
    this.date,
    this.attendees,
    this.location,
  );
  final String id, name, distance, date, location;
  final int attendees;
}

class RankEntry {
  const RankEntry(this.name, this.month, this.week, this.allTime, this.avatar);
  final String name;
  final double month, week, allTime;
  final int avatar;
  double score(int period) => switch (period) {
    0 => week,
    2 => allTime,
    _ => month,
  };
}
