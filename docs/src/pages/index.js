import React from 'react';
import clsx from 'clsx';
import Layout from '@theme/Layout';
import Link from '@docusaurus/Link';
import useDocusaurusContext from '@docusaurus/useDocusaurusContext';
import styles from './index.module.css';

function HomepageHeader() {
  const {siteConfig} = useDocusaurusContext();
  return (
    <header className={clsx('hero hero--primary', styles.heroBanner)}>
      <div className="container">
        <h1 className="hero__title">{siteConfig.title}</h1>
        <p className="hero__subtitle">{siteConfig.tagline}</p>
        <div className={styles.buttons}>
          <Link
            className="button button--secondary button--lg"
            to="/docs/intro">
            Get Started - 5min ⏱️
          </Link>
        </div>
      </div>
    </header>
  );
}

export default function Home() {
  const {siteConfig} = useDocusaurusContext();
  return (
    <Layout
      title={`${siteConfig.title}`}
      description="A comprehensive roleplay framework for FiveM">
      <HomepageHeader />
      <main>
        <div className="container margin-vert--xl">
          <div className="row">
            <div className="col col--4 margin-bottom--lg">
              <h2>Player Management</h2>
              <p>Complete player entity system with client and server-side components.</p>
            </div>
            <div className="col col--4 margin-bottom--lg">
              <h2>Inventory System</h2>
              <p>Weight-based inventory management with slots and capacity limits.</p>
            </div>
            <div className="col col--4 margin-bottom--lg">
              <h2>Equipment System</h2>
              <p>Clothing and equipment management with backpack capacity integration.</p>
            </div>
            <div className="col col--4 margin-bottom--lg">
              <h2>Database Integration</h2>
              <p>Data Access Object (DAO) pattern for clean database operations.</p>
            </div>
            <div className="col col--4 margin-bottom--lg">
              <h2>Shared Utilities</h2>
              <p>Common utilities and configuration shared between client and server.</p>
            </div>
            <div className="col col--4 margin-bottom--lg">
              <h2>Type Annotations</h2>
              <p>TypeScript-style type annotations for better IDE support and documentation.</p>
            </div>
          </div>
        </div>
      </main>
    </Layout>
  );
}

