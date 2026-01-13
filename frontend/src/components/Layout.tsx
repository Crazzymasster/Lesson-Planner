import { ReactNode } from 'react';
import { Link, useLocation } from 'react-router-dom';
import { 
  BookOpen, 
  Code, 
  Users, 
  LayoutDashboard, 
  Sparkles 
} from 'lucide-react';
import './Layout.css';

interface LayoutProps {
  children: ReactNode;
}

export default function Layout({ children }: LayoutProps) {
  const location = useLocation();

  const navItems = [
    { path: '/', icon: LayoutDashboard, label: 'Dashboard' },
    { path: '/lessons', icon: BookOpen, label: 'Lesson Plans' },
    { path: '/snippets', icon: Code, label: 'Code Snippets' },
    { path: '/groups', icon: Users, label: 'Student Groups' },
    { path: '/ai-assistant', icon: Sparkles, label: 'AI Assistant' },
  ];

  return (
    <div className="layout">
      <aside className="sidebar">
        <div className="sidebar-header">
          <BookOpen size={32} />
          <h1>Lesson Planner</h1>
        </div>
        <nav className="nav">
          {navItems.map((item) => {
            const Icon = item.icon;
            const isActive = location.pathname === item.path;
            return (
              <Link
                key={item.path}
                to={item.path}
                className={`nav-item ${isActive ? 'active' : ''}`}
              >
                <Icon size={20} />
                <span>{item.label}</span>
              </Link>
            );
          })}
        </nav>
      </aside>
      <main className="main-content">
        {children}
      </main>
    </div>
  );
}
