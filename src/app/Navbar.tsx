'use client';

import Link from 'next/link';

export const ExternalNavigation = () => {
  return (
    <header className="container mx-auto px-4 lg:px-6 h-14 flex items-center">
      <Link className="flex items-center justify-center" href="/">
        <span className="hidden lg:block ml-2 text-xl font-semibold text-gray-900 dark:text-gray-100">
          My real estate
        </span>
        <span className="block lg:hidden ml-2 text-xl font-semibold text-gray-900 dark:text-gray-100">
          My real estate
        </span>
      </Link>
      <nav className="ml-auto flex gap-4 sm:gap-6 items-center">
        <Link
          className="text-sm hidden lg:block font-medium hover:underline underline-offset-4"
          href="#"
        >
          Properties
        </Link>
        <Link
          className="text-sm hidden lg:block font-medium hover:underline underline-offset-4"
          href="#"
        >
          Listings
        </Link>
        <Link
          className="text-sm hidden lg:block font-medium hover:underline underline-offset-4"
          href="#"
        >
          Agents
        </Link>
        <Link
          className="text-sm hidden lg:block font-medium hover:underline underline-offset-4"
          href="/dashboard"
        >
          Dashboard
        </Link>
      </nav>
    </header>
  );
};
