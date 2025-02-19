import 'package:flutter/material.dart';
import 'package:flutter_s3_app/models/menu_item.dart';
import 'package:provider/provider.dart';

import '../providers/auth_provider.dart';

class CommonAppBar extends StatefulWidget implements PreferredSizeWidget {
  const CommonAppBar({super.key});

  @override
  State<CommonAppBar> createState() => _CommonAppBarState();

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}

class _CommonAppBarState extends State<CommonAppBar> {
  List<MenuItem> menuItems = [];

  @override
  void initState() {
    super.initState();
    _fetchMenuItems();
  }

  Future<void> _fetchMenuItems() async {
    try {
      // Заменить этот блок на метод получения меню из backend
      // Например:
      // final fetchedMenu = await BackendService.getMenuForUser();
      final fetchedMenu = [
        MenuItem(route: '/main', endpoint: '/dashboard', caption: 'Главная', icon: 'home', picture: 'home.jpg'),
        MenuItem(route: '/profile', endpoint: '/profile', caption: 'Профиль', icon: 'person', picture: 'profile.jpg'),
        // MenuItem(route: '/settings', endpoint: '/settings', caption: 'Настройки', icon: 'settings', picture: 'settings.jpg'),
        MenuItem(route: '/contracts', endpoint: '/contracts', caption: 'Договора', icon: 'description', picture: 'contracts.jpg'),
        MenuItem(route: '/payments', endpoint: '/payments', caption: 'Платежи', icon: 'attach_money', picture: 'payments.jpg'),
        MenuItem(route: '/electric_meter', endpoint: '/electric_meter', caption: 'Внесение показаний', icon: 'edit', picture: 'electric_meter.jpg'),
        MenuItem(route: '/electric_consumption', endpoint: '/electric_consumption', caption: 'Расход электроэнергии', icon: 'assessment', picture: 'electric_consumption.jpg'),
        MenuItem(route: '/expenses', endpoint: '/expenses', caption: 'Расходы', icon: 'credit_card', picture: 'credit_card.jpg'),
      ];
      setState(() {
        menuItems = fetchedMenu;
      });
    } catch (e) {
      // Обработка ошибок при загрузке меню
      print('Ошибка при загрузке меню: $e');
    }
  }

  void _logout() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    authProvider.logout();
    Navigator.pushReplacementNamed(context, '/login');
  }

  // Функция для маппинга строкового названия иконки на IconData
  IconData _getIconData(String iconName) {
    switch (iconName) {
      case 'home':
        return Icons.home;
      case 'person':
        return Icons.person;
      case 'settings':
        return Icons.settings;
      case 'payments':
        return Icons.payments;
      case 'electric_meter':
        return Icons.electric_meter;
      case 'electric_consumption':
        return Icons.electric_meter_sharp;
      case 'credit_card':
        return Icons.credit_card;
      case 'monetization_on':
        return Icons.monetization_on;
      case 'attach_money':
        return Icons.attach_money;
      case 'edit':
        return Icons.edit;
      case 'assessment':
        return Icons.assessment;
      case 'description':
        return Icons.description;
      default:
        return Icons.help;
    }
  }

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: const Text('Bitza'),
      leading: PopupMenuButton<MenuItem>(
        onSelected: (MenuItem item) {
          Navigator.pushNamed(context, item.route);
        },
        itemBuilder: (BuildContext context) {
          return menuItems.map((MenuItem item) {
            return PopupMenuItem<MenuItem>(
              value: item,
              child: Row(
                children: [
                  Icon(
                    _getIconData(item.icon),
                    color: Colors.black54,
                  ),
                  const SizedBox(width: 10),
                  Text(item.caption),
                ],
              ),
            );
          }).toList();
        },
        icon: const Icon(Icons.menu),
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.logout),
          onPressed: _logout,
          tooltip: 'Выйти',
        ),
      ],
    );
  }
}