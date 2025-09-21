'use client';
import { QueryClient, QueryClientProvider } from '@tanstack/react-query';
import { Fragment } from 'react';
import { Toaster } from 'react-hot-toast';
// Create a client
const queryClient = new QueryClient();
// This layout component can be used with React state, context and more as it is a client component.
export const ClientLayout = ({ children }: { children: React.ReactNode }) => {
  return (
    <Fragment>
      <QueryClientProvider client={queryClient}>{children}</QueryClientProvider>
      <Toaster />
    </Fragment>
  );
};
