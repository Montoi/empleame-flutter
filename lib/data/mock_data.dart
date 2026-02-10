import 'package:empleame/models/home_models.dart';

const userData = User(
  name: 'Andrew Ainsley',
  avatar: 'https://i.pravatar.cc/150?img=12',
  greeting: 'Good Morning',
  role: 'worker',
);

const specialOffers = [
  SpecialOffer(
    id: '1',
    discount: '50%',
    title: 'Emergency Services!',
    description: 'Professional firefighters ready 24/7 for your safety',
    bgColor: '#FF3B30',
    image:
        'https://images.unsplash.com/photo-1510515134701-443372c0cc95?w=400&q=80',
  ),
  SpecialOffer(
    id: '2',
    discount: '40%',
    title: 'Tech Experts!',
    description: 'Certified technicians for all your repair needs',
    bgColor: '#007AFF',
    image:
        'https://images.unsplash.com/photo-1581092160562-40aa08e78837?w=400&q=80',
  ),
  SpecialOffer(
    id: '3',
    discount: '30%',
    title: 'Deep Cleaning!',
    description: 'Professional cleaning service for your home or office',
    bgColor: '#7210FF',
    image:
        'https://images.unsplash.com/photo-1581578731548-c64695cc6952?w=400&q=80',
  ),
  SpecialOffer(
    id: '4',
    discount: '35%',
    title: 'Health Care!',
    description: 'Licensed nurses for home healthcare services',
    bgColor: '#34C759',
    image:
        'https://images.unsplash.com/photo-1576091160550-217359f4ecf8?w=400&q=80',
  ),
  SpecialOffer(
    id: '5',
    discount: '45%',
    title: 'Construction!',
    description: 'Expert builders for all your construction projects',
    bgColor: '#FF9500',
    image:
        'https://images.unsplash.com/photo-1504307651254-35680f356dfd?w=400&q=80',
  ),
];

const services = [
  Service(
    id: '1',
    name: 'Cleaning',
    icon: 'brush-outline',
    bgColor: '#EDE9FE',
    iconColor: '#7C3AED',
  ),
  Service(
    id: '2',
    name: 'Repairing',
    icon: 'build-outline',
    bgColor: '#FFEDD5',
    iconColor: '#EA580C',
  ),
  Service(
    id: '3',
    name: 'Painting',
    icon: 'color-fill-outline',
    bgColor: '#DBEAFE',
    iconColor: '#2563EB',
  ),
  Service(
    id: '4',
    name: 'Laundry',
    icon: 'water-outline',
    bgColor: '#FEF9C3',
    iconColor: '#CA8A04',
  ),
  Service(
    id: '5',
    name: 'Appliance',
    icon: 'tv-outline',
    bgColor: '#FEE2E2',
    iconColor: '#DC2626',
  ),
  Service(
    id: '6',
    name: 'Plumbing',
    icon: 'construct-outline',
    bgColor: '#D1FAE5',
    iconColor: '#059669',
  ),
  Service(
    id: '7',
    name: 'Shifting',
    icon: 'bus-outline',
    bgColor: '#CFFAFE',
    iconColor: '#0891B2',
  ),
  Service(
    id: '8',
    name: 'Beauty',
    icon: 'cut-outline',
    bgColor: '#FCE7F3',
    iconColor: '#DB2777',
  ),
  Service(
    id: '9',
    name: 'AC Repair',
    icon: 'snow-outline',
    bgColor: '#DCFCE7',
    iconColor: '#16A34A',
  ),
  Service(
    id: '10',
    name: 'Vehicle',
    icon: 'car-outline',
    bgColor: '#E0E7FF',
    iconColor: '#4F46E5',
  ),
  Service(
    id: '11',
    name: 'Electronics',
    icon: 'laptop-outline',
    bgColor: '#FEF3C7',
    iconColor: '#D97706',
  ),
  Service(
    id: '12',
    name: 'Massage',
    icon: 'leaf-outline',
    bgColor: '#FFE4E6',
    iconColor: '#E11D48',
  ),
  Service(
    id: '13',
    name: "Men's Salon",
    icon: 'person-outline',
    bgColor: '#F5F3FF',
    iconColor: '#7C3AED',
  ),
  Service(
    id: '14',
    name: 'More',
    icon: 'ellipsis-horizontal',
    bgColor: '#F8FAFC',
    iconColor: '#64748B',
  ),
];

const popularServices = [
  // Cleaning
  PopularService(
    id: '1',
    title: 'Full House Cleaning',
    category: 'Cleaning',
    provider: 'Kylee Danford',
    price: 25,
    rating: 4.8,
    reviewCount: 8289,
    image: 'https://images.unsplash.com/photo-1581578731548-c64695cc6952?w=400',
    isBookmarked: true,
  ),
  PopularService(
    id: '2',
    title: 'Deep Office Cleaning',
    category: 'Cleaning',
    provider: 'Alfonzo Schuessler',
    price: 30,
    rating: 4.7,
    reviewCount: 4210,
    image: 'https://images.unsplash.com/photo-1584622650111-993a426fbf0a?w=400',
    isBookmarked: false,
  ),
  // Repairing
  PopularService(
    id: '3',
    title: 'AC Repair & Service',
    category: 'Repairing',
    provider: 'Sarah Johnson',
    price: 45,
    rating: 4.9,
    reviewCount: 5120,
    image: 'https://images.unsplash.com/photo-1581092918056-0c4c3acd3789?w=400',
    isBookmarked: true,
  ),
  PopularService(
    id: '4',
    title: 'Fridge Maintenance',
    category: 'Repairing',
    provider: 'Bennie Woodbury',
    price: 35,
    rating: 4.6,
    reviewCount: 2150,
    image: 'https://images.unsplash.com/photo-1584622781564-1d987f7333c1?w=400',
    isBookmarked: false,
  ),
  // Painting
  PopularService(
    id: '5',
    title: 'Wall Painting',
    category: 'Painting',
    provider: 'Maricela Sullins',
    price: 22,
    rating: 4.8,
    reviewCount: 3120,
    image: 'https://images.unsplash.com/photo-1562564055-71e051d33c19?w=400',
    isBookmarked: false,
  ),
  PopularService(
    id: '6',
    title: 'Full House Painting',
    category: 'Painting',
    provider: 'Frederic Denney',
    price: 150,
    rating: 4.9,
    reviewCount: 1205,
    image: 'https://images.unsplash.com/photo-1589939705384-5185138a047a?w=400',
    isBookmarked: false,
  ),
  // More services...
  PopularService(
    id: '7',
    title: 'Dry Cleaning',
    category: 'Laundry',
    provider: 'Janetta Rotolo',
    price: 15,
    rating: 4.7,
    reviewCount: 2341,
    image: 'https://images.unsplash.com/photo-1517677208171-0bc6725a3e60?w=400',
    isBookmarked: true,
  ),
  PopularService(
    id: '8',
    title: 'TV Installation',
    category: 'Appliance',
    provider: 'Lauralee Quintera',
    price: 40,
    rating: 4.8,
    reviewCount: 5670,
    image: 'https://images.unsplash.com/photo-1593359677879-a4bb92f829d1?w=400',
    isBookmarked: false,
  ),
];

const categories = [
  'All',
  'Cleaning',
  'Repairing',
  'Painting',
  'Laundry',
  'Appliance',
  'Plumbing',
  'Shifting',
];
